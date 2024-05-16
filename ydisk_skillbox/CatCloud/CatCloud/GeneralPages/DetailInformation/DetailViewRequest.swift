//
//  DetailViewRequest.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 30.04.2024.
//

import Foundation
import UIKit
import PDFKit
import WebKit
import Alamofire

class DetailViewRequest {
    
    func renameFile(detail: Detail, name: String, completion: @escaping (Bool) -> Void) {
        guard let accessToken = TokenManager.shared.accessToken else {
            print ("Есть проблемы с авторизацией.")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "OAuth \(accessToken)"]
        
        let oldPath = detail.path
        let urlComponents = oldPath.components(separatedBy: ".")
        guard urlComponents.count >= 2 else {
            print("невозможно извлечь расширение из этого файла.")
            completion(false)
            return
        }
        let type = urlComponents.last!
        let lastIndex = oldPath.lastIndex(of: "/")!
        let change = String(oldPath[..<lastIndex])
        let newPath = "\(change)/\(name).\(type)"
        let url = "https://cloud-api.yandex.net/v1/disk/resources/move?from=\(oldPath)&path=\(newPath)"
        
        AF.request(url, method: .post, headers: headers).response { response in
            switch response.result {
            case .success (let data):
                if let httpResponse = response.response {
                    print("Код ответа сервера: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 201 {
                        print("Файл успешно переименован.")
                        completion(true)
                    } else {
                        if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                            print("Ошибка при переименовании \(responseString)")
                            completion(false)
                        } else {
                            print("Ошибка при переименовании файла.")
                            completion(false)
                        }
                    }
                }
            case .failure(let error):
                print("Ошибка переименования файла: \(error)")
                completion(false)
            }
        }
    }
    
    func deleteFile(detail: Detail) {
        
        guard let accessToken = TokenManager.shared.accessToken else {
            print ("Есть проблемы с авторизацией.")
            return
        }
        
        let path = detail.path
        let baseUrlString = "https://cloud-api.yandex.net/v1/disk/resources?path=\(path)"
        print("ссылка на удаление: \(baseUrlString)")
        let headers: HTTPHeaders = ["Authorization": "OAuth \(accessToken)"]
        let permanently = "true"
        
        AF.request(baseUrlString, method: .delete, parameters: ["permanently" : permanently], headers: headers ).responseData { response in
            switch response.result {
            case .success (let data):
                if let httpResponse = response.response {
                    if httpResponse.statusCode == 204 {
                        print("Удалось удалить файл.")
                    } else {
                        if let responseData = String(data: data, encoding: .utf8) {
                            print("Ошибка \(responseData)")
                        } else {
                            print("Ошибка. Не удалось получить данные с сервера.")
                        }
                    }
                } else {
                    print("Ошибка. Не удалось получить ответ сервера.")
                }
            case .failure(let error):
                print("Не удалось удалить файл, ошибка \(error.localizedDescription)")
            }
        }
    }
    
    func loadDetailInformation(for file: Detail, completion: @escaping (Result<(Detail, Data), Error>) -> Void) {
        
        guard let accessToken = TokenManager.shared.accessToken else {
            print ("Есть проблемы с авторизацией.")
            return
        }
        
        let path = file.path
        let baseUrlString = "https://cloud-api.yandex.net/v1/disk/resources"
        let headers: HTTPHeaders = ["Authorization": "OAuth \(accessToken)"]
        
        print("Создаем ссылку для запроса: \(baseUrlString)?path=\(path)")
        
        AF.request("\(baseUrlString)?path=\(path)", headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let detail = try decoder.decode(Detail.self, from: data)
                    self.loadFile(for: file) {fileResult in
                        switch fileResult {
                        case.success(let fileData):
                            completion(.success((detail, fileData)))
                        case.failure(let error):
                            completion(.failure(error))
                        }
                    }
                } catch {
                    completion(.failure(error))
                }
            case.failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadFile(for detail: Detail, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let accessToken = TokenManager.shared.accessToken else {
            print ("Есть проблемы с авторизацией.")
            return
        }
        
        let path = detail.path
        let baseUrlString = "https://cloud-api.yandex.net/v1/disk/resources/download?path=\(path)"
        let headers: HTTPHeaders = ["Authorization": "OAuth \(accessToken)"]
        print("ссылка на скачку: \(baseUrlString)")
        
        AF.request(baseUrlString, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                print("Удалось получить файл.")
                do {
                    let decoder = JSONDecoder()
                    let downloadInfo = try decoder.decode(DownloadInfo.self, from: data)
                    guard let downloadLink = downloadInfo.href else {
                        print("Ссылка для скачивания файла отсутствует в ответе.")
                        completion(.failure(NSError(domain: "loadFile", code: 0)))
                        return
                    }
                    print("ссылка на скачку самого файла: \(downloadLink)")
                    
                    AF.download(downloadLink).responseData { downloadResponse in
                        switch downloadResponse.result {
                        case .success(let fileData):
                            print("Файл скачен, успех!")
                            completion(.success(fileData))
                        case .failure(let error):
                            print("Не скачали файл, неудача!")
                            completion(.failure(error))
                        }
                    }
                }
                
                catch {
                    print("Ошибка декодирования.")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Не удалось выполнить запрос. полная неудача \(error)")
                completion(.failure(error))
            }
        }
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
    
    func getALink(detail: Detail, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "https://cloud-api.yandex.net/v1/disk/resources/publish?path="
        let path = detail.path
        
        guard let accessToken = TokenManager.shared.accessToken else {
            print("Ошибка: отсутствует токен доступа")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "OAuth \(accessToken)"]
        AF.request("\(url)\(path)", method: .put, headers: headers).responseDecodable(of: PublishResponse.self) { response in
            switch response.result {
            case .success(let publishResponse):
                    if let href = publishResponse.href {
                        AF.request(href, method: .get, headers: headers).responseDecodable(of: PublicURLResponse.self) { response in
                            switch response.result {
                            case .success(let publicURLResponse):
                                guard let publicURL = publicURLResponse.public_url else {
                                    print("Ошибка. Не удалось получить финальную публичную ссылку.")
                                    return
                                }
                                completion(.success(publicURL))
                            case .failure(let error):
                                print("Ошибка при получении финальной публичной ссылки: \(error.localizedDescription)")
                                completion(.failure(error))
                            }
                        }
                    }
            case .failure(let error):
                print("Ошибка \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
