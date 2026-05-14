import ActivityKit
import F1Core
import SwiftUI
import WidgetKit

private enum LiveCountdown {
    static func dhm(from now: Date, to target: Date) -> String {
        let seconds = max(0, target.timeIntervalSince(now))
        let d = Int(seconds) / 86_400
        let h = (Int(seconds) % 86_400) / 3_600
        let m = (Int(seconds) % 3_600) / 60
        if d > 0 { return "\(d)d \(h)h \(m)m" }
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

struct NextRaceLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NextRaceLiveAttributes.self) { context in
            TimelineView(PeriodicTimelineSchedule(from: Date(), by: 60)) { timeline in
                VStack(alignment: .leading, spacing: 8) {
                    Text("NEXT RACE")
                        .font(.custom("Orbitron-Bold", size: 11))
                        .foregroundStyle(.white.opacity(0.88))
                    Text(context.attributes.raceName)
                        .font(.custom("Orbitron-ExtraBold", size: 18))
                        .foregroundStyle(.white)
                    Text(context.attributes.circuitName)
                        .font(.custom("Orbitron-Regular", size: 13))
                        .foregroundStyle(.white.opacity(0.78))
                    Text(LiveCountdown.dhm(from: timeline.date, to: context.attributes.raceStart))
                        .font(.custom("Orbitron-ExtraBold", size: 30))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                }
                .padding()
            }
            .activityBackgroundTint(Color(red: 0.06, green: 0.06, blue: 0.07))
            .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    TimelineView(PeriodicTimelineSchedule(from: Date(), by: 60)) { timeline in
                        VStack(alignment: .leading) {
                            Text(context.attributes.raceName)
                                .font(.custom("Orbitron-Bold", size: 14))
                                .foregroundStyle(.white)
                            Text(context.attributes.circuitName)
                                .font(.custom("Orbitron-Regular", size: 11))
                                .foregroundStyle(.white.opacity(0.78))
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TimelineView(PeriodicTimelineSchedule(from: Date(), by: 60)) { timeline in
                        Text(LiveCountdown.dhm(from: timeline.date, to: context.attributes.raceStart))
                            .font(.custom("Orbitron-Bold", size: 22))
                            .foregroundStyle(.white)
                            .monospacedDigit()
                    }
                }
            } compactLeading: {
                Image(systemName: "flag.checkered")
                    .foregroundStyle(Color(red: 1, green: 0.09, blue: 0.02))
            } compactTrailing: {
                TimelineView(PeriodicTimelineSchedule(from: Date(), by: 60)) { timeline in
                    Text(LiveCountdown.dhm(from: timeline.date, to: context.attributes.raceStart))
                        .font(.custom("Orbitron-Bold", size: 11))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            } minimal: {
                Image(systemName: "flag.checkered.2.crossed")
                    .foregroundStyle(Color(red: 1, green: 0.09, blue: 0.02))
            }
        }
    }
}
