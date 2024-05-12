//
//  AllFilesModel.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 26.04.2024.
//

struct Info: Codable {
    let name: String
    let created: String
    let size: Int
    let preview: String?
    let mime_type: String
    let path: String
    let file: String?
    let href: String?

}

struct AllLoadFilesResponse: Codable {
    let items: [Info]
}

