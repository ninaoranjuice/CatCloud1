//
//  AllFilesRequests.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 26.04.2024.
//

import Foundation
import UIKit
import Alamofire

class AllFilesRequests {
    func loadAllFiles(offset: Int, completion: @escaping (Result<[Info], Error>) -> Void) {
        
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources/files"
        
        let parameters: [String: Any] = [
            "limit": "10",
            "offset": "\(offset)",
            "path": "",
            "fields": "preview, name, created, size",
            "preview_size": "M",
            "preview_crop": "true",
            "sort": "name"
        ]
        
        AF.request(urlString, parameters: parameters, headers: HTTPHeaders(["Authorization": "OAuth \(TokenManager.shared.accessToken ?? "")"])).responseDecodable(of: AllFilesResponse.self) { response in
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
        
    func loadContentsOfFolder(path: String, for viewController: AllFilesViewController, completion: @escaping ([Info]?) -> Void) {
           let baseURL = "https://cloud-api.yandex.net/v1/disk/resources"
           
           var components = URLComponents(string: baseURL)
           components?.queryItems = [
               URLQueryItem(name: "path", value: path)
           ]
           
           guard let url = components?.url else {
               print("Ошибка создания URL")
               completion(nil)
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           
           if let accessToken = TokenManager.shared.accessToken {
               request.setValue("OAuth \(accessToken)", forHTTPHeaderField: "Authorization")
               print("Токен доступа успешно добавлен к запросу.")
           } else {
               print("Проблемы с авторизацией.")
               completion(nil)
               return
           }
           
           print("Запрашиваемый URL: \(url.absoluteString)")
           
        AF.request(request).responseDecodable(of: AllFilesResponse.self) { response in
                switch response.result {
                case .success(let result):
                    if let embeddedItems = result.embedded?.items {
                        completion(embeddedItems)
                    } else {
                        print("Есть проблемы с запросом папки... ")
                        print("Вложено \(String(describing: result.embedded))")
                        completion(nil)
                    }
                case .failure(let error):
                    print("Ошибка при загрузке содержимого папки: \(error)")
                    completion(nil)
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
