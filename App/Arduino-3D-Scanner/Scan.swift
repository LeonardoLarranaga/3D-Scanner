//
//  Item.swift
//  Arduino-3D-Scanner
//
//  Created by Leonardo Larrañaga on 4/24/24.
//

import Foundation
import SwiftData

@Model
final class Scan: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var startTime: Date
    var endTime: Date
    var pointCloud: String
    
    init(title: String, startTime: Date, endTime: Date, pointCloud: String) {
        id = UUID()
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.pointCloud = pointCloud
    }
}
