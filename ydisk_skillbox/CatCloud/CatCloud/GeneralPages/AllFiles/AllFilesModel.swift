//
//  AllFilesModel.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 26.04.2024.
//
struct AllFilesResponse: Codable {
    let embedded: EmbeddedModel?
    let items: [Info]?
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case items
    }
}
struct EmbeddedModel: Codable {
    let items: [Info]
}
struct Info: Codable {
    let name: String
    let created: String
    let size: Int
    let preview: String?
    let mime_type: String
    let path: String
    let file: String?
    let href: String?
    let public_url: String?
    let type: String?


}

struct AllLoadFilesResponse: Codable {
    let items: [Info]
}

