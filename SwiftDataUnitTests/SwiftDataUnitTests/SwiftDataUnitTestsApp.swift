//
//  SwiftDataUnitTestsApp.swift
//  SwiftDataUnitTests
//
//  Created by Azizbek Asadov on 12/03/24.
//

import SwiftUI
import SwiftData

@main
struct SwiftDataUnitTestsApp: App {
    @Environment(\.modelContext) var modelContext
    let modelContainer: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: modelContext)
        }
        .modelContainer(modelContainer)
    }
    
    init() {
        var inMemory = false
        
        #if DEBUG
        if CommandLine.arguments.contains("enable-testing") {
            inMemory = true
        }
        #endif
        
        do {
            let configuration = ModelConfiguration(for: Movie.self, isStoredInMemoryOnly: inMemory)
            modelContainer = try ModelContainer(for: Movie.self, configurations: configuration)
        } catch {
            fatalError("Failed to load model container.")
        }
    }
}
