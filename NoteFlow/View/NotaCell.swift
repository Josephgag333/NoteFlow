//
//  NotaCell.swift
//  NoteFlow
//
//  Created by Renato Lopez on 27/12/25.
//

import UIKit

class NotaCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblTitulo: UILabel!
    @IBOutlet weak var lblContenido: UILabel!
    @IBOutlet weak var lblFecha: UILabel!
    @IBOutlet weak var btnEliminar: UIButton!
    @IBOutlet weak var btnEditar: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
    }

    func configurar(nota: Nota) {
        lblTitulo.text = nota.titulo
        lblContenido.text = nota.contenido
        lblFecha.text = nota.fecha_creacion.replacingOccurrences(of: "T", with: " ")
    }
}
