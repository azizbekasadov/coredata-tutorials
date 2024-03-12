//
//  ContentView.swift
//  iTour
//
//  Created by Azizbek Asadov on 09/03/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var path = [Destination]()
    @State private var sortOrder = SortDescriptor(\Destination.name)
    @State private var searchText = ""
    
    
    var body: some View {
        NavigationStack(path: $path) {
            DestinationListingView(sort: sortOrder, searchText: searchText)
            .navigationTitle("iTour")
            .searchable(text: $searchText)
            .navigationDestination(for: Destination.self, destination: EditDestinationView.init)
            .toolbar {
                Button("Add Samples", action: add)
                Button("Add Destination", systemImage: "plus", action: addDestination)
                
                Menu("Sort", systemImage: "arrow.up.arrow.down") {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Name")
                            .tag(SortDescriptor(\Destination.name))

                        Text("Priority")
                            .tag(SortDescriptor(\Destination.priority, order: .reverse))

                        Text("Date")
                            .tag(SortDescriptor(\Destination.date))
                    }
                    .pickerStyle(.inline)
                }
            }
        }
    }
    
    private func add() {
        ["Rome", "Florence", "Naples"].forEach {
            modelContext.insert(Destination(name: $0))
        }
    }
    
    private func addDestination() {
        let destination = Destination()
        modelContext.insert(destination)
        path = [destination]
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Destination.self, inMemory: true)
}
