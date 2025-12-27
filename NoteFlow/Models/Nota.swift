//
//  Nota.swift
//  NoteFlow
//
//  Created by Renato Lopez on 26/12/25.
//
import Foundation

struct Nota: Codable {
    let idNota: String
    let idUsuario: String
    let titulo: String
    let contenido: String
    let fecha_creacion: String
    let fecha_actualizacion: String
    let eliminada: Bool
}

