//
//  User.swift
//  SwiftDataPreload
//
//  Created by Azizbek Asadov on 12/03/24.
//

import Foundation
import SwiftData

@Model
class User: Codable {
    var name: String

    init(name: String) {
        self.name = name
    }
    
    enum CodingKeys: CodingKey {
        case name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}
