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
    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()
    
    private init() {}
    
    /// GET with `Accept: application/json` (Jolpi / Ergast mirrors).
    private func fetchJSON(path: String) async throws -> Data {
        let trimmed = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let urlString = "\(baseURL)/\(trimmed)"
        guard let url = URL(string: urlString) else {
            throw F1ServiceError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw F1ServiceError.invalidResponse
        }
        return data
    }
    
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
        do {
            let data = try await fetchJSON(path: "current.json")
            do {
                let ergastResponse = try jsonDecoder.decode(ErgastResponse.self, from: data)
                
                guard let races = ergastResponse.mrData.raceTable?.races else {
                    print("DEBUG ERROR: No races in response, using fallback")
                    return createFallbackRace()
                }
                
                let now = Date()
                let upcomingRaces = races.compactMap { race -> (Race, Date)? in
                    guard let raceDate = race.raceDate, raceDate > now else { return nil }
                    return (race, raceDate)
                }
                
                let nextRace = upcomingRaces
                    .sorted { $0.1 < $1.1 }
                    .first?.0
                
                if let race = nextRace {
                    print("DEBUG INFO: Found next race from API: \(race.raceName)")
                    return race
                } else {
                    print("DEBUG INFO: No upcoming races in current season schedule, using fallback")
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
            print("DEBUG ERROR: Request failed - \(error.localizedDescription), using fallback")
            return createFallbackRace()
        }
    }
    
    // MARK: - Fetch Driver Standings (current season + fallbacks)
    func fetchStandings() async -> (standings: [DriverStanding], season: Int) {
        if let parsed = await fetchDriverStandingsFromPath("current/driverStandings.json"), !parsed.standings.isEmpty {
            print("DEBUG INFO: Using current driver standings (season \(parsed.season))")
            return parsed
        }
        
        let calendarYear = Calendar.current.component(.year, from: Date())
        for year in [calendarYear, calendarYear - 1, calendarYear - 2] {
            if let list = await fetchStandingsForSeason(year), !list.isEmpty {
                print("DEBUG INFO: Using \(year) driver standings fallback")
                return (list, year)
            }
        }
        
        print("DEBUG ERROR: Driver standings unavailable")
        return ([], calendarYear)
    }
    
    private func fetchDriverStandingsFromPath(_ path: String) async -> (standings: [DriverStanding], season: Int)? {
        do {
            let data = try await fetchJSON(path: path)
            let ergastResponse = try jsonDecoder.decode(ErgastResponse.self, from: data)
            let list = ergastResponse.mrData.standingsTable?.standingsLists.first
            let standings = list?.driverStandings ?? []
            let season = Int(list?.season ?? "") ?? Calendar.current.component(.year, from: Date())
            return (standings, season)
        } catch {
            print("DEBUG ERROR: Driver standings path \(path) — \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchStandingsForSeason(_ year: Int) async -> [DriverStanding]? {
        let result = await fetchDriverStandingsFromPath("\(year)/driverStandings.json")
        return result?.standings
    }
    
    // MARK: - Fetch Constructor Standings (current season + fallbacks)
    func fetchConstructorStandings() async -> (standings: [ConstructorStanding], season: Int) {
        if let parsed = await fetchConstructorStandingsFromPath("current/constructorStandings.json"), !parsed.standings.isEmpty {
            print("DEBUG INFO: Using current constructor standings (season \(parsed.season))")
            return parsed
        }
        
        let calendarYear = Calendar.current.component(.year, from: Date())
        for year in [calendarYear, calendarYear - 1, calendarYear - 2] {
            if let list = await fetchConstructorStandingsForSeason(year), !list.isEmpty {
                print("DEBUG INFO: Using \(year) constructor standings fallback")
                return (list, year)
            }
        }
        
        print("DEBUG ERROR: Constructor standings unavailable")
        return ([], calendarYear)
    }
    
    private func fetchConstructorStandingsFromPath(_ path: String) async -> (standings: [ConstructorStanding], season: Int)? {
        do {
            let data = try await fetchJSON(path: path)
            let ergastResponse = try jsonDecoder.decode(ErgastResponse.self, from: data)
            let list = ergastResponse.mrData.standingsTable?.standingsLists.first
            let standings = list?.constructorStandings ?? []
            let season = Int(list?.season ?? "") ?? Calendar.current.component(.year, from: Date())
            return (standings, season)
        } catch {
            print("DEBUG ERROR: Constructor standings path \(path) — \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchConstructorStandingsForSeason(_ year: Int) async -> [ConstructorStanding]? {
        let result = await fetchConstructorStandingsFromPath("\(year)/constructorStandings.json")
        return result?.standings
    }
    
    // MARK: - Fetch Schedule (live season)
    func fetchSchedule() async -> [Race] {
        do {
            let data = try await fetchJSON(path: "current.json")
            do {
                let ergastResponse = try jsonDecoder.decode(ErgastResponse.self, from: data)
                return ergastResponse.mrData.raceTable?.races ?? []
            } catch {
                print("DEBUG ERROR: Schedule decode error — \(error)")
                return []
            }
        } catch {
            print("DEBUG ERROR: Schedule request failed — \(error.localizedDescription)")
            return []
        }
    }
    
    /// Winner per round from `current/results.json` (matches web dashboard data source).
    func fetchWinnersByRound() async -> [String: String] {
        do {
            let data = try await fetchJSON(path: "current/results.json?limit=1000")
            let response = try jsonDecoder.decode(ErgastResponse.self, from: data)
            guard let races = response.mrData.raceTable?.races else { return [:] }
            var winners: [String: String] = [:]
            for race in races {
                if let name = race.winnerFullName {
                    winners[race.round] = name
                }
            }
            return winners
        } catch {
            print("DEBUG ERROR: fetchWinnersByRound — \(error.localizedDescription)")
            return [:]
        }
    }
}
