//
//  CloudKitExpApp.swift
//  CloudKitExp
//
//  Created by Azizbek Asadov on 06/03/24.
//

import SwiftUI

@main
struct CloudKitExpApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
