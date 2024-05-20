//
//  PofileRequests.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 17.05.2024.
//

import Foundation
import Alamofire

class ProfileRequests {
    
    func loadInformation(completion: @escaping (Result<Diagramma, Error>) -> Void) {
        
        guard let accessToken = TokenManager.shared.accessToken else {
            print ("Есть проблемы с авторизацией.")
            return
        }
        
        let url = "https://cloud-api.yandex.net/v1/disk/"
        let headers: HTTPHeaders = ["Authorization": "OAuth \(accessToken)"]
        
        AF.request(url, method: .get, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let diagramma = try decoder.decode(Diagramma.self, from: data)
                    completion(.success(diagramma))
                } catch {
                    completion(.failure(error))
                }
            case.failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logOut() {
        SaveInfo.shared.deleteAllFiles()
        TokenManager.shared.clearToken()
        let register = MainViewController()
           UIApplication.shared.windows.first?.rootViewController = register
           UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}

