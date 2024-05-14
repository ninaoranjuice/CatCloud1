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
}

    
   
