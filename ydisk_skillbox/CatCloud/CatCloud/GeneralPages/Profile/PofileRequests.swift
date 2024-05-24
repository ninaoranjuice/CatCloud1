//
//  PofileRequests.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 17.05.2024.
//

import Foundation
import Alamofire
import WebKit

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
        TokenManager.shared.clearToken()
        SaveInfo.shared.deleteAllFiles()
        deleteCookies()
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        let register = MainViewController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = register
            window.makeKeyAndVisible()
        }
    }
    
    private func deleteCookies() {
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            for record in records {
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                    print("Куки удалены для \(record)")
                }
            }
        }
    }
}

