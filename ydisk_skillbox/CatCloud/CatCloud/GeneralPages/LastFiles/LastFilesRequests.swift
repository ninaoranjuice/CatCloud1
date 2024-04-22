//
//  Requests.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 18.04.2024.
//

import Foundation

class LastFilesRequests {
    
    func loadLastFiles(for viewController: LastFilesViewController) {
        let urlString = "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded"
        
        let parameters: [String: Any] = [
            "limit": "10",
            "media_type": "document,image,text,spreadsheet",
            "fields": "preview, name, created, size",
            "preview_size": "M",
            "preview_crop": "true"
        ]
        
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = parameters.map {URLQueryItem(name: $0.key, value: $0.value as? String)}
        
        guard let finalURL = urlComponents.url else {
            print("Ошибка при создании ссылки.")
            return
        }
        
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
}
