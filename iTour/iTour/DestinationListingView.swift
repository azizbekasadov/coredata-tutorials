//
//  DestinationListingView.swift
//  iTour
//
//  Created by Azizbek Asadov on 10/03/24.
//

import SwiftData
import SwiftUI

struct DestinationListingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Destination.priority, order: .reverse), SortDescriptor(\Destination.name)]) private var destinations: [Destination]
    
    var body: some View {
        List {
            ForEach(destinations) { destination in
                NavigationLink(value: destination) {
                    VStack(alignment: .leading) {
                        Text(destination.name)
                            .font(.headline)
                        Text(destination.date.formatted(date: .long, time: .shortened))
                    }
                }
            }
            .onDelete(perform: delete)
        }
    }
    
    init(sort: SortDescriptor<Destination>, searchText: String) {
    
        _destinations = Query(filter: #Predicate {
            searchText.isEmpty ? true : $0.name.localizedStandardContains(searchText)
        }, sort: [sort])
    }
    
    private func delete(_ indexSet: IndexSet) {
        for index in indexSet {
            let destination = destinations[index]
            modelContext.delete(destination)
        }
    }
}

#Preview {
    DestinationListingView(sort: SortDescriptor(\Destination.name), searchText: "")
}
