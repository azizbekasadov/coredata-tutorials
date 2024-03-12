//
//  NSSecureUnarchiveFromDataTransformer.swift
//  BowTies
//
//  Created by Azizbek Asadov on 25/02/24.
//  Copyright © 2024 Razeware. All rights reserved.
//

import Foundation
import UIKit

final class ColorAttributeTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
    }
  
    static func register() {
      let className = String(describing: ColorAttributeTransformer.self)
      let name = NSValueTransformerName(className)
      let transformer = ColorAttributeTransformer()
      ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
