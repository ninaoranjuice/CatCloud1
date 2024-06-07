//
//  PublicFilesRequests.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 23.05.2024.
//

import Foundation
import UIKit
import Alamofire

class PublicFilesRequests {
    
    func loadPublicFiles(for viewController: PublicFilesController, offset: Int) {
        let baseURL = "https://cloud-api.yandex.net/v1/disk/resources/public"
        let limit = "10"
        let fields = "preview, name, created, size, mime_type"
        let previewSize = "M"
        
        let parameters: Parameters = [
            "limit": limit,
            "fields": fields,
            "preview_size": previewSize,
            "offset": offset
        ]
        
        AF.request(baseURL, parameters: parameters, headers: HTTPHeaders(["Authorization": "OAuth \(TokenManager.shared.accessToken ?? "")"])).responseDecodable(of: PublicFilesResponse.self) { response in
            switch response.result {
            case .success(let result):
                guard let items = result.items else {
                    print(response)
                    print("Не найдено объектов вообще.")
                    return
                }
                DispatchQueue.main.async {
                    viewController.updateData(items)
                }
            case .failure(let error):
                print("Ошибка \(error)")
            }
        }
    }
    
    
    func loadContentsOfFolder(publicKey: String, path: String, for viewController: PublicFilesController, completion: @escaping ([PublicFiles]?) -> Void) {
        let baseURL = "https://cloud-api.yandex.net/v1/disk/public/resources"
        
        guard let _ = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            print("Ошибка кодирования пути")
            completion(nil)
            return
        }
        
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "public_key", value: publicKey),
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
            print("Токен, который добавили: \(accessToken)")
        } else {
            print("Проблемы с авторизацией.")
            completion(nil)
            return
        }
        print("Запрашиваемый URL: \(url.absoluteString)")
        
        AF.request(request).responseDecodable(of: PublicFilesResponse.self) { response in
            switch response.result {
            case .success(let result):
                print("РЕЗУЛЬТАТ ЗАПРОСА! \(result)")
                if let embeddedItems = result.embedded?.items {
                    DispatchQueue.main.async {
                        viewController.information = embeddedItems
                        viewController.tableView.reloadData()
                    }
                    completion(embeddedItems)
                } else {
                    print("Есть проблемы с запросом папки... ")
                    print("Вложно \(String(describing: result.embedded))")
                    completion(nil)
                }
            case .failure(let error):
                print("Ошибка при загрузке содержимого папки: \(error)")
                completion(nil)
            }
        }
    }
    
    func loadPreview(url: URL, mime_type: String?, completion: @escaping (UIImage?) -> Void) {
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
                print("Что-то пошло не так...")
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
    
    func unpublic(path: String, completion: @escaping (Error?) -> Void) {
        
        let urlString  = "https://cloud-api.yandex.net/v1/disk/resources/unpublish?path=\(path)"
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "PUT"
        
        if let accessToken = TokenManager.shared.accessToken {
            request.setValue("OAuth \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(nil)
            } else {
                completion(error)
            }
        }.resume()
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
