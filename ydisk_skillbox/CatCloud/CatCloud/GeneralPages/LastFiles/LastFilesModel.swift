//
//  LastFilesModel.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 18.04.2024.
//

struct Information: Codable {
    let name: String
    let created: String
    let size: Int
    let preview: String?
    let mime_type: String
    let path: String
    let file: String?
    let href: String?
    let public_url: String?

}

struct LastUploadFilesResponse: Codable {
    let items: [Information]
}
