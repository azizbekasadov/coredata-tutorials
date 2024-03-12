//
//  Item.swift
//  iTour
//
//  Created by Azizbek Asadov on 09/03/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
