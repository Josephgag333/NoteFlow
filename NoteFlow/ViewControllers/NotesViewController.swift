import UIKit

class NotesViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var notas: [Nota] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarTableView()
        cargarNotasUsuario()
    }

    // MARK: - Setup
    private func configurarTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
    }

    // MARK: - Data
    private func cargarNotasUsuario() {
        guard let idUsuario = UserDefaults.standard.string(forKey: "idUsuario") else {
            print("❌ No hay idUsuario en UserDefaults")
            return
        }

        SupabaseService.shared.obtenerNotas(idUsuario: idUsuario) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let notas):
                    self.notas = notas.filter { !$0.eliminada }
                    self.tableView.reloadData()

                case .failure(let error):
                    print("❌ Error al cargar notas:", error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func eliminarNota(_ sender: UIButton) {
        let index = sender.tag
        let nota = notas[index]

        SupabaseService.shared.eliminarNota(idNota: nota.idNota) {
            DispatchQueue.main.async {
                self.notas.remove(at: index)
                self.tableView.deleteRows(
                    at: [IndexPath(row: index, section: 0)],
                    with: .automatic
                )
            }
        }
    }

    @objc private func editarNota(_ sender: UIButton) {
        let nota = notas[sender.tag]
        print("✏️ Editar nota:", nota.titulo)
        // Luego navegas a EditNoteViewController
    }
}

// MARK: - UITableViewDataSource
extension NotesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notas.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "NotaCell",
            for: indexPath
        ) as? NotaCell else {
            return UITableViewCell()
        }

        let nota = notas[indexPath.row]
        cell.configurar(nota: nota)

        cell.btnEliminar.tag = indexPath.row
        cell.btnEditar.tag = indexPath.row

        cell.btnEliminar.addTarget(
            self,
            action: #selector(eliminarNota(_:)),
            for: .touchUpInside
        )

        cell.btnEditar.addTarget(
            self,
            action: #selector(editarNota(_:)),
            for: .touchUpInside
        )

        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotesViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
