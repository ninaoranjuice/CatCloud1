//
//  Constants.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 30.05.2024.
//

import Foundation


class Constants {
    enum Text {
        enum MainViewController {
            static let name = Bundle.main.localizedString(forKey: "name", value: "", table: "Localizable")
            static let login = Bundle.main.localizedString(forKey: "login", value: "", table: "Localizable")
        }
        enum TapBarController {
            static let profile = Bundle.main.localizedString(forKey: "profile", value: "", table: "Localizable")
            static let lastFile = Bundle.main.localizedString(forKey: "lastFile", value: "", table: "Localizable")
            static let allFile = Bundle.main.localizedString(forKey: "allFile", value: "", table: "Localizable")
        }
        
        enum Profile {
            static let freeMemory = Bundle.main.localizedString(forKey: "freeMemory", value: "", table: "Localizable")
            static let usedMemory = Bundle.main.localizedString(forKey: "usedMemory", value: "", table: "Localizable")
            static let publicButtonHeader = Bundle.main.localizedString(forKey: "publicButtonHeader", value: "", table: "Localizable")
            static let exitButtonHeader = Bundle.main.localizedString(forKey: "exitButtonHeader", value: "", table: "Localizable")
            static let diagrammaFree = Bundle.main.localizedString(forKey: "diagrammaFree", value: "", table: "Localizable")
            static let diagrammaUsed = Bundle.main.localizedString(forKey: "diagrammaUsed", value: "", table: "Localizable")
            static let gb = Bundle.main.localizedString(forKey: "gb", value: "", table: "Localizable")
            static let alertExit = Bundle.main.localizedString(forKey: "alertExit", value: "", table: "Localizable")
            static let alertMessage = Bundle.main.localizedString(forKey: "alertMessage", value: "", table: "Localizable")
            static let alertYes = Bundle.main.localizedString(forKey: "alertYes", value: "", table: "Localizable")
            static let alertCancel = Bundle.main.localizedString(forKey: "alertCancel", value: "", table: "Localizable")
            static let kb = Bundle.main.localizedString(forKey: "kb", value: "", table: "Localizable")
            static let create = Bundle.main.localizedString(forKey: "create", value: "", table: "Localizable")
            static let size = Bundle.main.localizedString(forKey: "size", value: "", table: "Localizable")
            static let empty = Bundle.main.localizedString(forKey: "empty", value: "", table: "Localizable")
            static let emptyMessage = Bundle.main.localizedString(forKey: "emptyMessage", value: "", table: "Localizable")
            static let ok = Bundle.main.localizedString(forKey: "ok", value: "", table: "Localizable")
            static let loadMore = Bundle.main.localizedString(forKey: "loadMore", value: "", table: "Localizable")
            static let back = Bundle.main.localizedString(forKey: "back", value: "", table: "Localizable")
            
        }
        
        enum DetailInformation {
            static let detailTitle = Bundle.main.localizedString(forKey: "detailTitle", value: "", table: "Localizable")
            static let detailName = Bundle.main.localizedString(forKey: "detailName", value: "", table: "Localizable")
            static let detailAlertName = Bundle.main.localizedString(forKey: "detailAlertName", value: "", table: "Localizable")
            static let detailAlertMessage = Bundle.main.localizedString(forKey: "detailAlertMessage", value: "", table: "Localizable")
            static let good = Bundle.main.localizedString(forKey: "good", value: "", table: "Localizable")
            static let goodMessage = Bundle.main.localizedString(forKey: "goodMessage", value: "", table: "Localizable")
            static let rename = Bundle.main.localizedString(forKey: "rename", value: "", table: "Localizable")
            static let newName = Bundle.main.localizedString(forKey: "newName", value: "", table: "Localizable")
            static let renameMessage = Bundle.main.localizedString(forKey: "renameMessage", value: "", table: "Localizable")
            static let save = Bundle.main.localizedString(forKey: "save", value: "", table: "Localizable")
        }
        
        enum Onboarding {
            static let firstName = Bundle.main.localizedString(forKey: "firstName", value: "", table: "Localizable")
            static let firstMessage = Bundle.main.localizedString(forKey: "firstMessage", value: "", table: "Localizable")
            static let secondName = Bundle.main.localizedString(forKey: "firstName", value: "", table: "Localizable")
            static let secondMessage = Bundle.main.localizedString(forKey: "secondMessage", value: "", table: "Localizable")
            static let thirdName = Bundle.main.localizedString(forKey: "thirdName", value: "", table: "Localizable")
            static let thirdMessage = Bundle.main.localizedString(forKey: "thirdMessage", value: "", table: "Localizable")
            static let next = Bundle.main.localizedString(forKey: "next", value: "", table: "Localizable")
        }
        
        enum Elements {
            static let link = Bundle.main.localizedString(forKey: "link", value: "", table: "Localizable")
            static let loading = Bundle.main.localizedString(forKey: "loading", value: "", table: "Localizable")
        }
    }
}
