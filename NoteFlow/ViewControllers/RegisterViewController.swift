import UIKit

class RegisterViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var txtNombre: UITextField!
    @IBOutlet weak var txtApellido: UITextField!
    @IBOutlet weak var txtCorreo: UITextField!
    @IBOutlet weak var txtContraseña: UITextField!
    @IBOutlet weak var btnRegistrar: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    @IBAction func registrarTapped(_ sender: UIButton) {

        guard
            let nombre = txtNombre.text, !nombre.isEmpty,
            let apellido = txtApellido.text, !apellido.isEmpty,
            let correo = txtCorreo.text, !correo.isEmpty,
            let contraseña = txtContraseña.text, !contraseña.isEmpty
        else {
            mostrarAlerta("Completa todos los campos")
            return
        }

        if contraseña.count < 6 {
            mostrarAlerta("La contraseña debe tener al menos 6 caracteres")
            return
        }

        registrarUsuario(
            nombre: nombre,
            apellido: apellido,
            correo: correo,
            contraseña: contraseña
        )
    }

    // MARK: - Registro completo
    private func registrarUsuario(
        nombre: String,
        apellido: String,
        correo: String,
        contraseña: String
    ) {

        SupabaseService.shared.signUp(
            email: correo,
            password: contraseña
        ) { result in

            DispatchQueue.main.async {
                switch result {
                case .success(let authResponse):
                    self.crearPerfilUsuario(
                        idUsuario: authResponse.userId,
                        nombre: nombre,
                        apellido: apellido,
                        correo: correo,
                        accessToken: authResponse.accessToken
                    )

                case .failure(let error):
                    self.mostrarAlerta("Error al registrar: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Insertar en tabla usuario
    private func crearPerfilUsuario(
        idUsuario: String,
        nombre: String,
        apellido: String,
        correo: String,
        accessToken: String
    ) {

        let usuario = Usuario(
            idUsuario: idUsuario,
            nombre: nombre,
            apellido: apellido,
            correo: correo,
            ocupacion: "",
            acerca_de: "",
            estado: "Activo",
            notas_creadas: nil,
            fecha_creacion: nil
        )


        SupabaseService.shared.crearUsuario(usuario: usuario) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    UserDefaults.standard.set(accessToken, forKey: "access_token")
                    UserDefaults.standard.set(idUsuario, forKey: "idUsuario")
                    self.irANotas()

                case .failure:
                    self.mostrarAlerta("No se pudo crear el perfil")
                }
            }
        }
    }

    // MARK: - Navegación
    private func irANotas() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotesViewController")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    // MARK: - Alert
    private func mostrarAlerta(_ mensaje: String) {
        let alert = UIAlertController(
            title: "NoteFlow",
            message: mensaje,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
