//
//  Race.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import Foundation

// MARK: - Ergast API Response Structure
struct ErgastResponse: Codable {
    let mrData: MRData
    
    enum CodingKeys: String, CodingKey {
        case mrData = "MRData"
    }
}

struct MRData: Codable {
    let raceTable: RaceTable?
    let standingsTable: StandingsTable?
    
    enum CodingKeys: String, CodingKey {
        case raceTable = "RaceTable"
        case standingsTable = "StandingsTable"
    }
}

// MARK: - Race Models
struct RaceTable: Codable {
    let races: [Race]
    
    enum CodingKeys: String, CodingKey {
        case races = "Races"
    }
}

struct Race: Codable, Identifiable {
    let id = UUID()
    let season: String
    let round: String
    let url: String
    let raceName: String
    let circuit: Circuit
    let date: String
    let time: String?
    let firstPractice: Session?
    let secondPractice: Session?
    let thirdPractice: Session?
    let qualifying: Session?
    let sprint: Session?
    
    enum CodingKeys: String, CodingKey {
        case season
        case round
        case url
        case raceName = "raceName"
        case circuit = "Circuit"
        case date
        case time
        case firstPractice = "FirstPractice"
        case secondPractice = "SecondPractice"
        case thirdPractice = "ThirdPractice"
        case qualifying = "Qualifying"
        case sprint = "Sprint"
    }
    
    var raceDate: Date? {
        // Strict date parsing: "2026-03-08" and "05:00:00Z"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        
        guard let baseDate = dateFormatter.date(from: date) else {
            print("DEBUG ERROR: Failed to parse race date: \(date)")
            return nil
        }
        
        // Ergast often omits `time` until confirmed; mirror web dashboard default (14:00 UTC).
        let rawTime = time?.trimmingCharacters(in: .whitespacesAndNewlines)
        let timeString = (rawTime?.isEmpty == false) ? rawTime! : "14:00:00Z"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let cleanTime = timeString.replacingOccurrences(of: "Z", with: "")
        
        if let parsedTime = timeFormatter.date(from: cleanTime) {
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: parsedTime)
            return calendar.date(bySettingHour: timeComponents.hour ?? 14,
                               minute: timeComponents.minute ?? 0,
                               second: timeComponents.second ?? 0,
                               of: baseDate)
        }
        
        return baseDate
    }
    
    var isUpcoming: Bool {
        guard let raceDate = raceDate else { return false }
        return raceDate > Date()
    }
}

struct Circuit: Codable {
    let circuitId: String
    let url: String
    let circuitName: String
    let location: Location
    
    enum CodingKeys: String, CodingKey {
        case circuitId = "circuitId"
        case url
        case circuitName = "circuitName"
        case location = "Location"
    }
}

struct Location: Codable {
    let lat: String
    let long: String
    let locality: String
    let country: String
}

struct Session: Codable {
    let date: String
    let time: String
}

