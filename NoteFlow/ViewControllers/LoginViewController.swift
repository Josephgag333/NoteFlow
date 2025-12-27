//
//  ViewController.swift
//  NoteFlow
//
//  Created by Renato Lopez on 26/12/25.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtCorreo: UITextField!
    
    @IBOutlet weak var txtContraseña: UITextField!
    
    @IBOutlet weak var btnIngresar: UIButton!
    
    @IBOutlet weak var btnGo: UIButton!
    
    @IBAction func irARegistro(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "RegisterViewController"
        )
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    
    @IBAction func ingresarTapped(_ sender: UIButton) {
        
        guard let email = txtCorreo.text, !email.isEmpty,
              let password = txtContraseña.text, !password.isEmpty else {
            mostrarAlerta("Completa todos los campos")
            return
        }

        SupabaseService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let idUsuario):
                    print("Login OK, idUsuario:", idUsuario)
                    self.irANotas()

                case .failure:
                    self.mostrarAlerta("Correo o contraseña incorrectos")
                }
            }
        }
    }
    
    func irANotas() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotesViewController")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func mostrarAlerta(_ mensaje: String) {
        let alert = UIAlertController(
            title: "NoteFlow",
            message: mensaje,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}

