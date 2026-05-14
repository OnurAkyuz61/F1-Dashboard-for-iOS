import ActivityKit
import F1Core
import SwiftUI
import WidgetKit

struct NextRaceLiveActivityWidget: Widget {
    var body: some Widget {
        ActivityConfiguration(for: NextRaceLiveAttributes.self) { context in
            VStack(alignment: .leading, spacing: 8) {
                Text("NEXT RACE")
                    .font(.custom("Orbitron-Bold", size: 11))
                    .foregroundStyle(.secondary)
                Text(context.attributes.raceName)
                    .font(.custom("Orbitron-ExtraBold", size: 18))
                Text(context.attributes.circuitName)
                    .font(.custom("Orbitron-Regular", size: 13))
                    .foregroundStyle(.secondary)
                Text(context.attributes.raceStart, style: .timer)
                    .font(.custom("Orbitron-Bold", size: 32))
                    .foregroundStyle(.red)
            }
            .padding()
            .activityBackgroundTint(Color(red: 0.06, green: 0.06, blue: 0.06))
            .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text(context.attributes.raceName)
                            .font(.custom("Orbitron-Bold", size: 14))
                        Text(context.attributes.circuitName)
                            .font(.custom("Orbitron-Regular", size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.raceStart, style: .timer)
                        .font(.custom("Orbitron-Bold", size: 22))
                        .foregroundStyle(.red)
                }
            } compactLeading: {
                Image(systemName: "flag.checkered")
                    .foregroundStyle(.red)
            } compactTrailing: {
                Text(context.attributes.raceStart, style: .timer)
                    .font(.custom("Orbitron-Bold", size: 12))
                    .monospacedDigit()
            } minimal: {
                Image(systemName: "flag.checkered.2.crossed")
                    .foregroundStyle(.red)
            }
        }
    }
}
