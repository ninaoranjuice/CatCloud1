//
//  DetailViewModel.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 30.04.2024.
//

struct Detail: Codable {
    let name: String
    let created: String
    let mime_type: String
    let path: String
    let file: String?
    let href: String?
    let public_url: String?
}

struct DownloadInfo: Codable {
    let href: String?
}

struct PublishResponse: Codable {
    let href: String?
}

struct PublicURLResponse: Codable {
    let public_url: String?
}





