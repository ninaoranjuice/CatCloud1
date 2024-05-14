//
//  SaveInfo.swift
//  CatCloud
//
//  Created by Нина Гурстиева on 10.05.2024.
//

import UIKit
import CoreData

class SaveInfo {
   
    static let shared = SaveInfo()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "File")
        container.loadPersistentStores(completionHandler: {
            (storeDesctiption, error) in
            if let error = error as NSError? {
                fatalError("Неразрешимая ошибка \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveFile(_ data: Data, fileName: String) {
        let context = persistentContainer.viewContext
        let entityDesciption = NSEntityDescription.entity(forEntityName: "File", in: context)!
        let file = NSManagedObject(entity: entityDesciption, insertInto: context)
        
        file.setValue(data, forKey: "data")
        file.setValue(fileName, forKey: "name")
        
        do {
            try context.save()
            print("Удалось успешно сохранить файл.")
        } catch {
            print("Ошибка сохранения файла \(error.localizedDescription)")
        }
    }
    
    func getFileData(fileName: String) -> Data? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "File")
        fetchRequest.predicate = NSPredicate(format: "name == %@", fileName)
        
        do {
            let result = try context.fetch(fetchRequest)
            if let file = result.first as? NSManagedObject, let data = file.value(forKey: "data") as? Data {
                print("Данные для файла успешно загружены из базы данных.")
                return data
            } else {
                print("Данные для файла не обнаружены в базе данных.")
                return nil
            }
        } catch {
            print("Ошибка чтения из базы данных \(error.localizedDescription)")
            return nil
        }
    }
}
  
