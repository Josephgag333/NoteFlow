//
//  SupabaseService.swift
//  NoteFlow
//
//  Created by Renato Lopez on 27/12/25.
//

import Foundation

class SupabaseService {

    static let shared = SupabaseService()

    private let baseURL = "https://wimcdgvtehzitwupmplt.supabase.co/rest/v1"
    private let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndpbWNkZ3Z0ZWh6aXR3dXBtcGx0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY4NDMyMjAsImV4cCI6MjA4MjQxOTIyMH0.M9k-Zna_4Sdp54VY5Jgb4yinT8UAPB4iau2Y7SNYbc8"

    private init() {}

    // MARK: - Request base
    private func createRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) -> URLRequest {

        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)

        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "apikey")

        let accessToken = UserDefaults.standard.string(forKey: "access_token")
        let bearer = accessToken ?? apiKey
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        return request
    }


    // MARK: - POST Usuario
    func crearUsuario(
        usuario: Usuario,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        let endpoint = "/usuario"

        let body: [String: Any] = [
            "nombre": usuario.nombre,
            "apellido": usuario.apellido,
            "correo": usuario.correo,
            "ocupacion": usuario.ocupacion ?? "",
            "acerca_de": usuario.acerca_de ?? "",
            "estado": usuario.estado
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        let request = createRequest(
            endpoint: endpoint,
            method: "POST",
            body: jsonData
        )

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }.resume()
    }

    // MARK: - POST Nota
    func crearNota(
        idUsuario: String,
        titulo: String,
        contenido: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {

        let endpoint = "/nota"

        let body: [String: Any] = [
            "idUsuario": idUsuario,
            "titulo": titulo,
            "contenido": contenido
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        let request = createRequest(
            endpoint: endpoint,
            method: "POST",
            body: jsonData
        )

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }.resume()
    }
    
    // MARK: - LOGIN (Supabase Auth)
    func login(
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        let url = URL(string: "https://wimcdgvtehzitwupmplt.supabase.co/auth/v1/token?grant_type=password")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")

        let body: [String: Any] = [
            "email": email,
            "password": password
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                if let accessToken = json?["access_token"] as? String,
                   let user = json?["user"] as? [String: Any],
                   let userId = user["id"] as? String {

                    // Guardamos sesión
                    UserDefaults.standard.set(accessToken, forKey: "access_token")
                    UserDefaults.standard.set(userId, forKey: "idUsuario")

                    completion(.success(userId))

                } else {
                    completion(.failure(NSError(domain: "LoginError", code: 401)))
                }

            } catch {
                completion(.failure(error))
            }

        }.resume()
    }
    
    func eliminarNota(idNota: String, completion: @escaping () -> Void) {

        let body = [
            "eliminada": true
        ]

        let data = try? JSONSerialization.data(withJSONObject: body)

        let request = createRequest(
            endpoint: "/nota?idNota=eq.\(idNota)",
            method: "PATCH",
            body: data
        )

        URLSession.shared.dataTask(with: request) { _, _, _ in
            completion()
        }.resume()
    }

    
    // MARK: - GET Notas
    func obtenerNotas(
        idUsuario: String,
        completion: @escaping (Result<[Nota], Error>) -> Void
    ) {

        let endpoint = "/nota?idUsuario=eq.\(idUsuario)&order=fecha_creacion.desc"

        let request = createRequest(endpoint: endpoint)

        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let notas = try JSONDecoder().decode([Nota].self, from: data)
                completion(.success(notas))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    // MARK: - SIGN UP (Supabase Auth) ✅ CORRECTO
    func signUp(
        email: String,
        password: String,
        completion: @escaping (Result<(userId: String, accessToken: String), Error>) -> Void
    ) {

        let url = URL(string: "https://wimcdgvtehzitwupmplt.supabase.co/auth/v1/signup")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")

        let body: [String: Any] = [
            "email": email,
            "password": password
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                if
                    let accessToken = json?["access_token"] as? String,
                    let user = json?["user"] as? [String: Any],
                    let userId = user["id"] as? String {

                    completion(.success((userId, accessToken)))

                } else {
                    print("❌ Signup response:", json ?? [:])
                    completion(.failure(NSError(domain: "SignupError", code: 400)))
                }

            } catch {
                completion(.failure(error))
            }

        }.resume()
    }

}

