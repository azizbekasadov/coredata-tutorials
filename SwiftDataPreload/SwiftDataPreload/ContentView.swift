//
//  ContentView.swift
//  SwiftDataPreload
//
//  Created by Azizbek Asadov on 12/03/24.
//

import SwiftUI
import SwiftData
import CoreData

struct ContentView: View {
    @Query var users: [User]
    
    var body: some View {
        if users.isEmpty {
            VStack {
                Button("Create Data") { create() }
                    .buttonStyle(.borderedProminent)
            }
        } else {
            NavigationStack {
                List(users) { user in
                    Text(user.name)
                }
                .navigationTitle("Users")
            }
        }
    }
    
    private func create() {
        let container = NSPersistentContainer(name: "Model")
        let storeURL = URL.documentsDirectory.appending(path: "users.store")

        if let description = container.persistentStoreDescriptions.first {
            try? FileManager.default.removeItem(at: storeURL)
            description.url = storeURL
            description.setValue("DELETE" as NSObject, forPragmaNamed: "journal_mode")
        }
        
        container.loadPersistentStores { description, error in
            do {
                for i in 1...10_000 {
                    let user = User(context: container.viewContext)
                    user.name = "User \(i)"
                    container.viewContext.insert(user)
                }
                
                try container.viewContext.save()
                let destination = URL(filePath: "/Users/azizbekasadov/Desktop/users.store")
                try FileManager.default.copyItem(at: storeURL, to: destination)
            } catch let error as NSError {
                print("Failed to create data: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
