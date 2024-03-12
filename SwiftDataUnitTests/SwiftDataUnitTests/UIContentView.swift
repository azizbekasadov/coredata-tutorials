//
//  UIContentView.swift
//  SwiftDataUnitTests
//
//  Created by Azizbek Asadov on 12/03/24.
//

import SwiftData
import SwiftUI

struct UIContentView: View {
    @Query(sort: \Movie.name) var movies: [Movie]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
            List(movies) { movie in
                VStack(alignment: .leading) {
                    Text(movie.name)
                        .font(.headline)
                    
                    Text("Directed by: \(movie.director)")
                }
            }
            .navigationTitle("MovieDB")
            .toolbar {
                Button("Add Samples", action: addSamples)
            }
        }
    }
    
    func addSamples() {
        let redOctober = Movie(name: "The Hunt for Red October", director: "John McTiernan", releaseYear: 1990)
        let sneakers = Movie(name: "Sneakers", director: "Phil Alden Robinson", releaseYear: 1992)
        let endLiss = Movie(name: "Endliss Possibilities: The Casey Liss Story", director: "Erin Liss", releaseYear: 2006)
        
        modelContext.insert(redOctober)
        modelContext.insert(sneakers)
        modelContext.insert(endLiss)
    }
    
    func clear() {
        try? modelContext.delete(model: Movie.self)
    }
}
