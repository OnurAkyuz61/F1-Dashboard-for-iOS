//
//  F1DataService.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import Foundation

enum F1ServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

class F1DataService {
    static let shared = F1DataService()
    private let baseURL = "https://api.jolpi.ca/ergast/f1"
    
    private init() {}
    
    // MARK: - Fallback Race (Fail-Safe)
    func createFallbackRace() -> Race? {
        // Create fallback Australian Grand Prix for 2026-03-08
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let fallbackDate = dateFormatter.date(from: "2026-03-08") ?? Date()
        let dateString = dateFormatter.string(from: fallbackDate)
        
        let mockJSON = """
        {
            "season": "2026",
            "round": "1",
            "url": "https://en.wikipedia.org/wiki/2026_Australian_Grand_Prix",
            "raceName": "Australian Grand Prix",
            "Circuit": {
                "circuitId": "albert_park",
                "url": "http://en.wikipedia.org/wiki/Albert_Park_Grand_Prix_Circuit",
                "circuitName": "Albert Park Grand Prix Circuit",
                "Location": {
                    "lat": "-37.8497",
                    "long": "144.9680",
                    "locality": "Melbourne",
                    "country": "Australia"
                }
            },
            "date": "\(dateString)",
            "time": "05:00:00Z"
        }
        """
        
        guard let data = mockJSON.data(using: .utf8) else {
            print("DEBUG ERROR: Failed to create fallback race data - this should never happen")
            // Last resort: return a minimal race object
            return createMinimalFallbackRace()
        }
        
        let decoder = JSONDecoder()
        if let race = try? decoder.decode(Race.self, from: data) {
            print("DEBUG INFO: Using fallback Australian Grand Prix race")
            return race
        }
        
        print("DEBUG ERROR: Failed to decode fallback race, using minimal fallback")
        return createMinimalFallbackRace()
    }
    
    // MARK: - Minimal Fallback (Last Resort)
    private func createMinimalFallbackRace() -> Race? {
        // Absolute last resort - create race directly from JSON string
        let minimalJSON = """
        {"season":"2026","round":"1","url":"","raceName":"Australian Grand Prix","Circuit":{"circuitId":"albert_park","url":"","circuitName":"Albert Park Grand Prix Circuit","Location":{"lat":"-37.8497","long":"144.9680","locality":"Melbourne","country":"Australia"}},"date":"2026-03-08","time":"05:00:00Z"}
        """
        
        guard let data = minimalJSON.data(using: .utf8),
              let race = try? JSONDecoder().decode(Race.self, from: data) else {
            print("DEBUG CRITICAL: Even minimal fallback failed - this is a critical error")
            return nil
        }
        return race
    }
    
    // MARK: - Fetch Next Race (Fail-Safe)
    func fetchNextRace() async -> Race? {
        // Fetch full 2026 schedule
        let urlString = "\(baseURL)/2026.json"
        guard let url = URL(string: urlString) else {
            print("DEBUG ERROR: Invalid URL - \(urlString), using fallback")
            return createFallbackRace()
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("DEBUG ERROR: Invalid HTTP response - Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0), using fallback")
                return createFallbackRace()
            }
            
            let decoder = JSONDecoder()
            do {
                let ergastResponse = try decoder.decode(ErgastResponse.self, from: data)
                
                guard let races = ergastResponse.mrData.raceTable?.races else {
                    print("DEBUG ERROR: No races in response, using fallback")
                    return createFallbackRace()
                }
                
                // Find first upcoming race using Race model's raceDate property
                let now = Date()
                let upcomingRaces = races.compactMap { race -> (Race, Date)? in
                    guard let raceDate = race.raceDate, raceDate > now else { return nil }
                    return (race, raceDate)
                }
                
                // Sort by date and return the first one
                let nextRace = upcomingRaces
                    .sorted { $0.1 < $1.1 }
                    .first?.0
                
                if let race = nextRace {
                    print("DEBUG INFO: Found next race from API: \(race.raceName)")
                    return race
                } else {
                    print("DEBUG INFO: No upcoming races found in 2026 schedule, using fallback")
                    return createFallbackRace()
                }
            } catch let decodingError as DecodingError {
                print("DEBUG ERROR: Decoding error - \(decodingError), using fallback")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("DEBUG ERROR: Type mismatch - Expected \(type) at path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("DEBUG ERROR: Value not found - Expected \(type) at path: \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("DEBUG ERROR: Key not found - \(key.stringValue) at path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("DEBUG ERROR: Data corrupted at path: \(context.codingPath)")
                @unknown default:
                    print("DEBUG ERROR: Unknown decoding error")
                }
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("DEBUG ERROR: Response JSON (first 1000 chars): \(String(jsonString.prefix(1000)))")
                }
                return createFallbackRace()
            }
        } catch {
            print("DEBUG ERROR: Network error - \(error.localizedDescription), using fallback")
            return createFallbackRace()
        }
    }
    
    // MARK: - Fetch Driver Standings (with Auto-Switch Season)
    func fetchStandings() async -> (standings: [DriverStanding], season: Int) {
        // Try 2026 first
        if let standings2026 = await fetchStandingsForSeason(2026), !standings2026.isEmpty {
            print("DEBUG INFO: Using 2026 driver standings")
            return (standings2026, 2026)
        }
        
        // Fallback to 2025
        print("DEBUG INFO: 2026 standings empty, falling back to 2025")
        if let standings2025 = await fetchStandingsForSeason(2025), !standings2025.isEmpty {
            print("DEBUG INFO: Using 2025 driver standings")
            return (standings2025, 2025)
        }
        
        print("DEBUG ERROR: Both 2026 and 2025 standings are empty")
        return ([], 2026)
    }
    
    private func fetchStandingsForSeason(_ year: Int) async -> [DriverStanding]? {
        let urlString = "\(baseURL)/\(year)/driverStandings.json"
        guard let url = URL(string: urlString) else {
            print("DEBUG ERROR: Invalid URL - \(urlString)")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("DEBUG ERROR: Invalid HTTP response for \(year) - Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return nil
            }
            
            let decoder = JSONDecoder()
            do {
                let ergastResponse = try decoder.decode(ErgastResponse.self, from: data)
                let standings = ergastResponse.mrData.standingsTable?.standingsLists.first?.driverStandings ?? []
                return standings
            } catch let decodingError as DecodingError {
                print("DEBUG ERROR: Decoding error for \(year) - \(decodingError)")
                return nil
            }
        } catch {
            print("DEBUG ERROR: Network error for \(year) - \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Fetch Constructor Standings (with Auto-Switch Season)
    func fetchConstructorStandings() async -> (standings: [ConstructorStanding], season: Int) {
        // Try 2026 first
        if let standings2026 = await fetchConstructorStandingsForSeason(2026), !standings2026.isEmpty {
            print("DEBUG INFO: Using 2026 constructor standings")
            return (standings2026, 2026)
        }
        
        // Fallback to 2025
        print("DEBUG INFO: 2026 constructor standings empty, falling back to 2025")
        if let standings2025 = await fetchConstructorStandingsForSeason(2025), !standings2025.isEmpty {
            print("DEBUG INFO: Using 2025 constructor standings")
            return (standings2025, 2025)
        }
        
        print("DEBUG ERROR: Both 2026 and 2025 constructor standings are empty")
        return ([], 2026)
    }
    
    private func fetchConstructorStandingsForSeason(_ year: Int) async -> [ConstructorStanding]? {
        let urlString = "\(baseURL)/\(year)/constructorStandings.json"
        guard let url = URL(string: urlString) else {
            print("DEBUG ERROR: Invalid URL - \(urlString)")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("DEBUG ERROR: Invalid HTTP response for \(year) - Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return nil
            }
            
            let decoder = JSONDecoder()
            do {
                let ergastResponse = try decoder.decode(ErgastResponse.self, from: data)
                let standings = ergastResponse.mrData.standingsTable?.standingsLists.first?.constructorStandings ?? []
                return standings
            } catch let decodingError as DecodingError {
                print("DEBUG ERROR: Decoding error for \(year) - \(decodingError)")
                return nil
            }
        } catch {
            print("DEBUG ERROR: Network error for \(year) - \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Fetch Schedule
    func fetchSchedule() async -> [Race] {
        let urlString = "\(baseURL)/2026.json"
        guard let url = URL(string: urlString) else {
            print("DEBUG ERROR: Invalid URL - \(urlString)")
            return []
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("DEBUG ERROR: Invalid HTTP response - Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return []
            }
            
            let decoder = JSONDecoder()
            do {
                let ergastResponse = try decoder.decode(ErgastResponse.self, from: data)
                let races = ergastResponse.mrData.raceTable?.races ?? []
                return races
            } catch let decodingError as DecodingError {
                print("DEBUG ERROR: Decoding error - \(decodingError)")
                return []
            }
        } catch {
            print("DEBUG ERROR: Network error - \(error.localizedDescription)")
            return []
        }
    }
}
