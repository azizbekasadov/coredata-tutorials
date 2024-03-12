//
//  PersonEntity.swift
//  HitList
//
//  Created by Azizbek Asadov on 25/02/24.
//

import Foundation
import CoreData

//func save(name: String) {
//  guard let appDelegate =
//    UIApplication.shared.delegate as? AppDelegate else {
//return
//}
//// 1
//  let managedContext =
//    appDelegate.persistentContainer.viewContext
//// 2
//  let entity =
//    NSEntityDescription.entity(forEntityName: "Person",
//                               in: managedContext)!
//  let person = NSManagedObject(entity: entity,
//                               insertInto: managedContext)
//// 3
//  person.setValue(name, forKeyPath: "name")
//// 4
//  do {
//    try managedContext.save()
//    people.append(person)
//  } catch let error as NSError {
//    print("Could not save. \(error), \(error.userInfo)")
//  }
//}

enum CoreDataError: Error {
    case invalidContext
    case invalidEntity
    case invalidSaving
    case emptyContext
}

protocol CoreDataManager {
    func fetch(entityName: String, completion: @escaping ((Result<[NSManagedObject], CoreDataError>) -> Void))
    func save(entity: Decodable, completion: @escaping ((Result<Void, CoreDataError>) -> Void))
}

final class HLCoreDataManager: CoreDataManager {
    
    private var container: NSPersistentContainer
    
    init(container: NSPersistentContainer) {
        self.container = container
    }
    
    func fetch(entityName: String, completion: @escaping ((Result<[NSManagedObject], CoreDataError>) -> Void)) {
        let context = container.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName + "Entity")
        
        do {
            let entities = try context.fetch(fetchRequest)
            
            if entities.isEmpty {
                completion(.failure(.emptyContext))
            } else {
                completion(.success(entities))
            }
        } catch {
            completion(.failure(.invalidEntity))
        }
    }
    
    func save(entity: Decodable, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        let context = container.viewContext
        
        if let _entity = NSEntityDescription.entity(
            forEntityName: String(describing: type(of: entity)) + "Entity",
            in: context
        ) {
            let object = NSManagedObject(entity: _entity, insertInto: context)
            let properties = properties(structure: entity)
            properties.forEach { object.setValue($0.value, forKey: $0.key) }
            
            do {
                try context.save()
                completion(.success(())) // Looks weird, agree
            } catch {
                completion(.failure(.invalidSaving))
            }
        } else {
            completion(.failure(.invalidEntity))
        }
    }
    
    
}

fileprivate func properties<T>(structure: T)  -> [(key: String, value: Any)] {
    Mirror(reflecting: structure).children.compactMap {
        if let key = $0.label {
            return (key, $0.value)
        }
        return nil
    }
}
