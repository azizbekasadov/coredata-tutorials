//
//  CoreDataStack.swift
//  DogWalk
//
//  Created by Azizbek Asadov on 25/02/24.
//  Copyright © 2024 Razeware. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataStack {
  private let modelName: String
  
  lazy var managedContext: NSManagedObjectContext = {
      self.storeContainer.viewContext
  }()
  
  init(modelName: String) {
    self.modelName = modelName
  }
  
  private lazy var storeContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: self.modelName)
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  func saveContext () {
    guard managedContext.hasChanges else { return }
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Unresolved error \(error), \(error.userInfo)")
    }
  }
}
