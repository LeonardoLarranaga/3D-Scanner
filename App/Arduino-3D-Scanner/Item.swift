//
//  Item.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 4/24/24.
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
