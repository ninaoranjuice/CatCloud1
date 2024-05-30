//
//  Requests.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 18.04.2024.
//

import Foundation
import UIKit

class LastFilesRequests {
    func loadLastFiles(for viewController: LastFilesViewController) {
        
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded"
        
        let parameters: [String: Any] = [
            "limit": "10",
            "fields": "preview, name, created, size",
            "preview_size": "M",
            "preview_crop": "true"
        ]
        
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value as? String)
        }
        
        guard let finalURL = urlComponents.url else {
            print("Ошибка при создании ссылки.")
            return
        }
        print(finalURL)
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        
        if let accessToken = TokenManager.shared.accessToken {
            request.setValue("OAuth \(accessToken)", forHTTPHeaderField: "Authorization")
        
            print("Токен доступа успешно добавлен к запросу.")
            print("Токен, который добавили: \(accessToken)")
        } else {
            print("Проблемы с авторизацией.")
        }
        

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка: \(error)")
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                guard let response = response as? HTTPURLResponse else {
                    print("Не удалось получить HTTP-ответ")
                    return
                }

                print("Код состояния HTTP-ответа: \(response.statusCode)")
                return
            }
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(LastUploadFilesResponse.self, from: data)
                    DispatchQueue.main.async {
                        viewController.updateData(result.items)
                    }
                }
                catch {
                    print ("Ошибка декодирования \(error)")
                }
            }
        }
        task.resume()
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
