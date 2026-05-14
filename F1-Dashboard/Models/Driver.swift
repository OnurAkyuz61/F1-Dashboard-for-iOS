//
//  Driver.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import Foundation
import SwiftUI

// MARK: - Driver Standings Models
struct StandingsTable: Codable {
    let standingsLists: [StandingsList]
    
    enum CodingKeys: String, CodingKey {
        case standingsLists = "StandingsLists"
    }
}

struct StandingsList: Codable {
    let season: String
    let round: String
    let driverStandings: [DriverStanding]?
    let constructorStandings: [ConstructorStanding]?
    
    enum CodingKeys: String, CodingKey {
        case season
        case round
        case driverStandings = "DriverStandings"
        case constructorStandings = "ConstructorStandings"
    }
}

struct DriverStanding: Codable, Identifiable {
    let id = UUID()
    let position: String
    let positionText: String
    let points: String
    let wins: String
    let driver: Driver
    let constructors: [Constructor]
    
    enum CodingKeys: String, CodingKey {
        case position
        case positionText = "positionText"
        case points
        case wins
        case driver = "Driver"
        case constructors = "Constructors"
    }
    
    var positionInt: Int {
        Int(position) ?? 0
    }
    
    var pointsInt: Int {
        Int(points) ?? 0
    }
}

struct Driver: Codable, Identifiable {
    let id = UUID()
    let driverId: String
    let permanentNumber: String?
    let code: String?
    let url: String
    let givenName: String
    let familyName: String
    let dateOfBirth: String
    let nationality: String
    
    enum CodingKeys: String, CodingKey {
        case driverId = "driverId"
        case permanentNumber = "permanentNumber"
        case code
        case url
        case givenName = "givenName"
        case familyName = "familyName"
        case dateOfBirth = "dateOfBirth"
        case nationality
    }
    
    var fullName: String {
        "\(givenName) \(familyName)"
    }
    
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        return components.compactMap { $0.first }.map { String($0) }.joined()
    }

    /// Given name (Orbitron, dim) + family name (Orbitron, bold) in one `Text` — avoids deprecated `Text`+`Text` (iOS 26+).
    func orbitronDisplayNameAttributed(
        size: CGFloat = 17,
        givenWeight: Font.Weight = .regular,
        familyWeight: Font.Weight = .bold,
        givenForegroundOpacity: Double = 0.6
    ) -> AttributedString {
        var givenPart = AttributedString("\(givenName) ")
        givenPart.font = AppFont.orbitron(size, weight: givenWeight)
        givenPart.foregroundColor = Color.white.opacity(givenForegroundOpacity)

        var familyPart = AttributedString(familyName)
        familyPart.font = AppFont.orbitron(size, weight: familyWeight)
        familyPart.foregroundColor = Color.white

        return givenPart + familyPart
    }
}

