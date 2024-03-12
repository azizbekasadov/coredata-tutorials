//
//  ContentView.swift
//  SwiftDataUnitTests
//
//  Created by Azizbek Asadov on 12/03/24.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @State private var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.movies) { movie in
                VStack(alignment: .leading) {
                    Text(movie.name)
                        .font(.headline)
                    
                    Text("Directed by: \(movie.director)")
                }
            }
            .navigationTitle("MovieDB")
            .toolbar {
                Button("Add Samples", action: viewModel.addSamples)
                Button("Clear", action: viewModel.clear)
            }
        }
    }
    
    init(modelContext: ModelContext) {
        let viewModel = ViewModel(modelContext: modelContext)
        _viewModel = State(initialValue: viewModel)
    }
}

extension ContentView {
    
    @Observable
    final class ViewModel {
        private let modelContext: ModelContext
        private(set) var movies = [Movie]()
        
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            fetchData()
        }

        private func fetchData() {
            do {
                let descriptor = FetchDescriptor<Movie>(sortBy: [SortDescriptor(\.name)])
                movies = try modelContext.fetch(descriptor)
            } catch {
                print("Fetch failed")
            }
        }
        
        func addSamples() {
            let redOctober = Movie(name: "The Hunt for Red October", director: "John McTiernan", releaseYear: 1990)
            let sneakers = Movie(name: "Sneakers", director: "Phil Alden Robinson", releaseYear: 1992)
            let endLiss = Movie(name: "Endliss Possibilities: The Casey Liss Story", director: "Erin Liss", releaseYear: 2006)
            
            modelContext.insert(redOctober)
            modelContext.insert(sneakers)
            modelContext.insert(endLiss)
            try? modelContext.save()
            fetchData()
        }
        
        func clear() {
            try? modelContext.delete(model: Movie.self)
            try? modelContext.save()
            fetchData()
        }
    }
}
