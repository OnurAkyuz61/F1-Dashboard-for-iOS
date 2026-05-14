import ActivityKit
import Foundation

/// Shared between the app and widget extension for Live Activities.
public struct NextRaceLiveAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        public var phase: String
        
        public init(phase: String = "") {
            self.phase = phase
        }
    }
    
    public var raceName: String
    public var circuitName: String
    public var raceStart: Date
    
    public init(raceName: String, circuitName: String, raceStart: Date) {
        self.raceName = raceName
        self.circuitName = circuitName
        self.raceStart = raceStart
    }
}
