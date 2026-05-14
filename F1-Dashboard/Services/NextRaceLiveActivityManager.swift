import ActivityKit
import F1Core
import Foundation

@MainActor
enum NextRaceLiveActivityManager {
    static func syncLiveActivity(for race: Race, enabled: Bool) async {
        guard enabled else {
            await endAll()
            return
        }
        guard ActivityAuthorizationInfo().areActivitiesEnabled,
              let start = race.raceDate,
              start > Date() else {
            await endAll()
            return
        }
        
        let attributes = NextRaceLiveAttributes(
            raceName: race.raceName,
            circuitName: race.circuit.circuitName,
            raceStart: start
        )
        let state = NextRaceLiveAttributes.ContentState(phase: "countdown")
        let content = ActivityContent(state: state, staleDate: start)
        
        for activity in Activity<NextRaceLiveAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        
        do {
            _ = try Activity.request(attributes: attributes, content: content, pushType: nil)
        } catch {
            print("DEBUG: Live Activity request failed: \(error)")
        }
    }
    
    static func endAll() async {
        for activity in Activity<NextRaceLiveAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
