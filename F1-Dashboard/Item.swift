//
//  Item.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
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
