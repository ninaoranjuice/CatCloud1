//
//  TokenManager.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 17.04.2024.
//

import Foundation

class TokenManager {
    static let shared = TokenManager()
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "AccessToken"
    
    var accessToken: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        }
        
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
    
    func clearToken() {
        userDefaults.set(nil, forKey: tokenKey)
            print("Токен очищен: \(accessToken)")
    }
}
