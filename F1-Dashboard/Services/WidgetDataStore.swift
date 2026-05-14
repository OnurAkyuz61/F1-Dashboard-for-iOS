import F1Core
import Foundation
import WidgetKit

enum WidgetDataStore {
    static func save(nextRace: Race) {
        guard let start = nextRace.raceDate else { return }
        let payload = NextRaceWidgetPayload(
            raceName: nextRace.raceName,
            circuitName: nextRace.circuit.circuitName,
            round: nextRace.round,
            season: nextRace.season,
            raceStart: start
        )
        guard let data = try? JSONEncoder().encode(payload),
              let defaults = UserDefaults(suiteName: NextRaceWidgetPayload.appGroupIdentifier) else { return }
        defaults.set(data, forKey: NextRaceWidgetPayload.userDefaultsKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
