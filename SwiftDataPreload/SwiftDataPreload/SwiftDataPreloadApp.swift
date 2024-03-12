//
//  SwiftDataPreloadApp.swift
//  SwiftDataPreload
//
//  Created by Azizbek Asadov on 12/03/24.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataPreloadApp: App {
    let container: ModelContainer

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: User.self) { results in
            do {
                let container = try results.get()
                
                // Check we haven't already added our users.
                let descriptor = FetchDescriptor<User>()
                let existingUsers = try container.mainContext.fetchCount(descriptor)
                
                guard existingUsers == 0 else { return }
                
                // Load and decode the JSON.
                guard let url = Bundle.main.url(forResource: "Users", withExtension: "json") else {
                    fatalError("Failed to find users.json")
                }
                
                let data = try Data(contentsOf: url)
                let users = try JSONDecoder().decode([User].self, from: data)
                
                // Add all our data to the context.
                for user in users {
                    container.mainContext.insert(user)
                }
            } catch {
                print("Failed to pre-seed database.")
            }
        }
    }
    
    init() {
        do {
            guard let storeURL = Bundle.main.url(forResource: "users", withExtension: "store") else {
                fatalError("Failed to find users.store")
            }
            
            let config = ModelConfiguration(url: storeURL)
            container = try ModelContainer(for: User.self, configurations: config)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }
}

//If you'd like to save yourself some headaches, I'd suggest you go to your target's build settings and set Strict Concurrency Checking to Complete, then follow the instructions below in order to get concurrency right.
