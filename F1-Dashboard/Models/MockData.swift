//
//  MockData.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import Foundation

// MARK: - Mock Data Factory
struct MockData {
    // MARK: - Race Mock Data
    static func mockNextRace() -> Race? {
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: nextMonth)
        let timeString = "05:00:00Z"
        
        // Create mock JSON and decode it
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
            "time": "\(timeString)"
        }
        """
        
        guard let data = mockJSON.data(using: .utf8) else { return nil }
        let decoder = JSONDecoder()
        if let race = try? decoder.decode(Race.self, from: data) {
            return race
        }
        // If decoding fails, return nil - the service will handle this
        print("DEBUG ERROR: Failed to decode mock race data")
        return nil
    }
    
    // MARK: - Driver Standings Mock Data
    static func mockStandings() -> [DriverStanding] {
        let mockJSON = """
        [
            {
                "position": "1",
                "positionText": "1",
                "points": "285",
                "wins": "7",
                "Driver": {
                    "driverId": "norris",
                    "permanentNumber": "4",
                    "code": "NOR",
                    "url": "http://en.wikipedia.org/wiki/Lando_Norris",
                    "givenName": "Lando",
                    "familyName": "Norris",
                    "dateOfBirth": "1999-11-13",
                    "nationality": "British"
                },
                "Constructors": [{
                    "constructorId": "mclaren",
                    "url": "http://en.wikipedia.org/wiki/McLaren",
                    "name": "McLaren",
                    "nationality": "British"
                }]
            },
            {
                "position": "2",
                "positionText": "2",
                "points": "275",
                "wins": "5",
                "Driver": {
                    "driverId": "verstappen",
                    "permanentNumber": "33",
                    "code": "VER",
                    "url": "http://en.wikipedia.org/wiki/Max_Verstappen",
                    "givenName": "Max",
                    "familyName": "Verstappen",
                    "dateOfBirth": "1997-09-30",
                    "nationality": "Dutch"
                },
                "Constructors": [{
                    "constructorId": "red_bull",
                    "url": "http://en.wikipedia.org/wiki/Red_Bull_Racing",
                    "name": "Red Bull Racing",
                    "nationality": "Austrian"
                }]
            },
            {
                "position": "3",
                "positionText": "3",
                "points": "245",
                "wins": "4",
                "Driver": {
                    "driverId": "hamilton",
                    "permanentNumber": "44",
                    "code": "HAM",
                    "url": "http://en.wikipedia.org/wiki/Lewis_Hamilton",
                    "givenName": "Lewis",
                    "familyName": "Hamilton",
                    "dateOfBirth": "1985-01-07",
                    "nationality": "British"
                },
                "Constructors": [{
                    "constructorId": "mercedes",
                    "url": "http://en.wikipedia.org/wiki/Mercedes-Benz_in_Formula_One",
                    "name": "Mercedes",
                    "nationality": "German"
                }]
            }
        ]
        """
        
        guard let data = mockJSON.data(using: .utf8) else { 
            print("DEBUG ERROR: Failed to create mock standings data")
            return [] 
        }
        let decoder = JSONDecoder()
        if let standings = try? decoder.decode([DriverStanding].self, from: data) {
            return standings
        }
        print("DEBUG ERROR: Failed to decode mock standings data")
        return []
    }
    
    // MARK: - Race Schedule Mock Data
    static func mockSchedule() -> [Race] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let races = [
            ("1", "Australian Grand Prix", "albert_park", "Albert Park Grand Prix Circuit", "Melbourne", "Australia", Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()),
            ("2", "Chinese Grand Prix", "shanghai", "Shanghai International Circuit", "Shanghai", "China", Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date()),
            ("3", "Bahrain Grand Prix", "bahrain", "Bahrain International Circuit", "Sakhir", "Bahrain", Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()),
            ("4", "Saudi Arabian Grand Prix", "jeddah", "Jeddah Corniche Circuit", "Jeddah", "Saudi Arabia", Calendar.current.date(byAdding: .month, value: 4, to: Date()) ?? Date()),
            ("5", "Monaco Grand Prix", "monaco", "Circuit de Monaco", "Monte-Carlo", "Monaco", Calendar.current.date(byAdding: .month, value: 5, to: Date()) ?? Date())
        ]
        
        var mockRaces: [Race] = []
        
        for (round, raceName, circuitId, circuitName, locality, country, date) in races {
            let dateString = dateFormatter.string(from: date)
            let mockJSON = """
            {
                "season": "2026",
                "round": "\(round)",
                "url": "https://en.wikipedia.org/wiki/2026_\(raceName.replacingOccurrences(of: " ", with: "_"))",
                "raceName": "\(raceName)",
                "Circuit": {
                    "circuitId": "\(circuitId)",
                    "url": "http://en.wikipedia.org/wiki/\(circuitName.replacingOccurrences(of: " ", with: "_"))",
                    "circuitName": "\(circuitName)",
                    "Location": {
                        "lat": "0",
                        "long": "0",
                        "locality": "\(locality)",
                        "country": "\(country)"
                    }
                },
                "date": "\(dateString)",
                "time": "05:00:00Z"
            }
            """
            
            guard let data = mockJSON.data(using: .utf8),
                  let race = try? JSONDecoder().decode(Race.self, from: data) else {
                continue
            }
            mockRaces.append(race)
        }
        
        return mockRaces
    }
    
    // MARK: - Constructor Standings Mock Data
    static func mockConstructorStandings() -> [ConstructorStanding] {
        let mockJSON = """
        [
            {
                "position": "1",
                "positionText": "1",
                "points": "833",
                "wins": "19",
                "Constructor": {
                    "constructorId": "red_bull",
                    "url": "http://en.wikipedia.org/wiki/Red_Bull_Racing",
                    "name": "Red Bull Racing",
                    "nationality": "Austrian"
                }
            },
            {
                "position": "2",
                "positionText": "2",
                "points": "675",
                "wins": "3",
                "Constructor": {
                    "constructorId": "mclaren",
                    "url": "http://en.wikipedia.org/wiki/McLaren",
                    "name": "McLaren",
                    "nationality": "British"
                }
            },
            {
                "position": "3",
                "positionText": "3",
                "points": "542",
                "wins": "1",
                "Constructor": {
                    "constructorId": "ferrari",
                    "url": "http://en.wikipedia.org/wiki/Scuderia_Ferrari",
                    "name": "Ferrari",
                    "nationality": "Italian"
                }
            },
            {
                "position": "4",
                "positionText": "4",
                "points": "456",
                "wins": "0",
                "Constructor": {
                    "constructorId": "mercedes",
                    "url": "http://en.wikipedia.org/wiki/Mercedes-Benz_in_Formula_One",
                    "name": "Mercedes",
                    "nationality": "German"
                }
            },
            {
                "position": "5",
                "positionText": "5",
                "points": "398",
                "wins": "0",
                "Constructor": {
                    "constructorId": "aston_martin",
                    "url": "http://en.wikipedia.org/wiki/Aston_Martin_in_Formula_One",
                    "name": "Aston Martin",
                    "nationality": "British"
                }
            },
            {
                "position": "6",
                "positionText": "6",
                "points": "312",
                "wins": "0",
                "Constructor": {
                    "constructorId": "alpine",
                    "url": "http://en.wikipedia.org/wiki/Alpine_F1_Team",
                    "name": "Alpine",
                    "nationality": "French"
                }
            }
        ]
        """
        
        guard let data = mockJSON.data(using: .utf8) else {
            print("DEBUG ERROR: Failed to create mock constructor standings data")
            return []
        }
        let decoder = JSONDecoder()
        if let standings = try? decoder.decode([ConstructorStanding].self, from: data) {
            return standings
        }
        print("DEBUG ERROR: Failed to decode mock constructor standings data")
        return []
    }
}

