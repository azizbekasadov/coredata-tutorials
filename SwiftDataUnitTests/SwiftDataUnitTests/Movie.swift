//
//  Movie.swift
//  SwiftDataUnitTests
//
//  Created by Azizbek Asadov on 12/03/24.
//

import Foundation
import SwiftData

@Model
class Movie {
    var name: String
    var director: String
    var releaseYear: Int

    init(name: String, director: String, releaseYear: Int) {
        self.name = name
        self.director = director
        self.releaseYear = releaseYear
    }
}
