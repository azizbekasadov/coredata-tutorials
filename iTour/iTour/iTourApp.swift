//
//  iTourApp.swift
//  iTour
//
//  Created by Azizbek Asadov on 09/03/24.
//

import SwiftUI
import SwiftData

@main
struct iTourApp: App {
    private var config: ModelStorageConfigration = .init()
    
    //let config = ModelConfiguration(allowsSave: false) for sensitive data

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(config.container)
    }
}


final class ModelStorageConfigration {
    var container: ModelContainer
    
    init() {
        do {
            let storeURL = URL.documentsDirectory.appending(path: "database.sqlite")
            let config = ModelConfiguration(url: storeURL)
            container = try ModelContainer(for: Destination.self, configurations: config)
            
//            let storeURL = URL.documentsDirectory.appending(path: "database.sqlite")
//            let schema = Schema([Recipe.self, User.self])
//            let config = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .private("pastalavista"))
//            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
}

// SwiftData Savings
//Exactly when it happens is an implementation detail, but from what I can tell it's in the following circumstances:
//
//Every time the app goes to the background
//Every time the app moves back to the foreground
//Every time the current runloop ends



//@main
//struct RecipeBookApp: App {
//    var container: ModelContainer
//
//    init() {
//        do {
//            let config1 = ModelConfiguration(for: Recipe.self)
//            let config2 = ModelConfiguration(for: Comment.self, isStoredInMemoryOnly: true)
//
//            container = try ModelContainer(for: Recipe.self, Comment.self, configurations: config1, config2)
//        } catch {
//            fatalError("Failed to configure SwiftData container.")
//        }
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(container)
//    }
//}
