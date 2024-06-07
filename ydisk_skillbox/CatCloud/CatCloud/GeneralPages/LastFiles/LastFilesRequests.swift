//
//  Requests.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 18.04.2024.
//

import Foundation
import UIKit
import Alamofire

class LastFilesRequests {
    func loadLastFiles(completion: @escaping (Result<[Information], Error>) -> Void) {
        
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded"
        
        let parameters: [String: Any] = [
            "limit": "10",
            "fields": "preview, name, created, size",
            "preview_size": "M",
            "preview_crop": "true"
        ]
        
        AF.request(urlString, parameters: parameters, headers: HTTPHeaders(["Authorization": "OAuth \(TokenManager.shared.accessToken ?? "")"])).responseDecodable(of: LastUploadFilesResponse.self) { response in
            switch response.result {
            case .success(let result):
                guard let items = result.items else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не найдено объектов."])))
                    return
                }
                completion(.success(items))
            case .failure(let error):
                print("Ошибка \(error)")
            }
        }
    }
    
    func loadPreview(url: URL, mime_type: String, completion: @escaping (UIImage?) -> Void) {
        
        var request = URLRequest(url: url)
        if let accessToken = TokenManager.shared.accessToken {
            request.setValue("OAuth \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Возникла ошибка \(error)")
                completion(nil)
                return
            }
            guard let data = data else {
                print("Не удалось получить данные")
                completion(nil)
                return
            }
            if let image = UIImage(data: data) {
                completion(image)
            } else {
                print ("Что-то пошло не так...")
                let icon: UIImage
                switch mime_type {
                case "application/pdf": icon = UIImage(named: "doc_icon")!
                case "image/jpeg": icon = UIImage(named: "image_icon")!
                case "image/png": icon = UIImage(named: "image_icon")!
                case "image/gif": icon = UIImage(named: "image_icon")!
                case "application/msword": icon = UIImage(named: "doc_icon")!
                case "application/vnd.openxmlformats-officedocument.wordprocessingml.document": icon = UIImage(named: "doc_icon")!
                case "application/rtf": icon = UIImage(named: "doc_icon")!
                case "application/vnd.ms-powerpoint": icon = UIImage(named: "doc_icon")!
                case "application/vnd.openxmlformats-officedocument.presentationml.presentation": icon = UIImage(named: "doc_icon")!
                case "application/vnd.ms-excel": icon = UIImage(named: "doc_icon")!
                case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": icon = UIImage(named: "doc_icon")!
                default: icon = UIImage(named: "unknown_icon")!
                }
                completion(icon)
            }
        }
            task.resume()
    }
    
    func formatDate(_ dateS: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        if let date = dateFormatter.date(from: dateS) {
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            return dateFormatter.string(from: date)
        } else {
            return nil
        }
    }
}
