//
//  Constructor.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import Foundation

struct ConstructorStanding: Codable, Identifiable {
    let id = UUID()
    let position: String
    let positionText: String
    let points: String
    let wins: String
    let constructor: Constructor
    
    enum CodingKeys: String, CodingKey {
        case position
        case positionText = "positionText"
        case points
        case wins
        case constructor = "Constructor"
    }
    
    var positionInt: Int {
        Int(position) ?? 0
    }
    
    var pointsInt: Int {
        Int(points) ?? 0
    }
}

struct Constructor: Codable, Identifiable {
    let id = UUID()
    let constructorId: String
    let url: String
    let name: String
    let nationality: String
    
    enum CodingKeys: String, CodingKey {
        case constructorId = "constructorId"
        case url
        case name
        case nationality
    }
}

