import Foundation

public struct NextRaceWidgetPayload: Codable, Sendable {
    public static let appGroupIdentifier = "group.onurakyuz.F1-Dashboard"
    public static let userDefaultsKey = "nextRaceWidgetPayload"
    
    public var raceName: String
    public var circuitName: String
    public var round: String
    public var season: String
    public var raceStart: Date
    
    public init(raceName: String, circuitName: String, round: String, season: String, raceStart: Date) {
        self.raceName = raceName
        self.circuitName = circuitName
        self.round = round
        self.season = season
        self.raceStart = raceStart
    }
    
    public static func load() -> NextRaceWidgetPayload? {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = defaults.data(forKey: userDefaultsKey) else { return nil }
        return try? JSONDecoder().decode(NextRaceWidgetPayload.self, from: data)
    }
}
