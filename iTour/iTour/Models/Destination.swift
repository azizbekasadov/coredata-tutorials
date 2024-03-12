//
//  Destination.swift
//  iTour
//
//  Created by Azizbek Asadov on 09/03/24.
//

import Foundation
import SwiftData

@Model
final class Destination {
    var name: String
    var details: String
    var date: Date
    var priority: Int
    @Relationship(deleteRule: .cascade) var sights = [Sight]()
    
    init(name: String = "", details: String = "", date: Date = .now, priority: Int = 2) {
        self.name = name
        self.details = details
        self.date = date
        self.priority = priority
    }
}

