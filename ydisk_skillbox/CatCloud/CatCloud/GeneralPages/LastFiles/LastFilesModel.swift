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
    let preview: String
}

struct LastUploadFilesResponse: Codable {
    let items: [Information]
    let limit: Int
}
