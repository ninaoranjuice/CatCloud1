//
//  PublicFilesModel.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 23.05.2024.
//

struct PublicFilesResponse: Codable {
    let embedded: Embedded?
    let items: [PublicFiles]?
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case items
    }
}

struct Embedded: Codable {
    let items: [PublicFiles]
}

struct PublicFiles: Codable {
    let name: String
    let created: String
    let size: Int?
    let preview: String?
    let mime_type: String?
    let path: String?
    let file: String?
    let href: String?
    let public_url: String?
    let type: String
    let public_key: String?
}
