import ActivityKit
import F1Core
import SwiftUI
import UIKit
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

    /// Shorter string for compact Dynamic Island / pill.
    static func dhmCompact(from now: Date, to target: Date) -> String {
        let seconds = max(0, target.timeIntervalSince(now))
        let d = Int(seconds) / 86_400
        let h = (Int(seconds) % 86_400) / 3_600
        let m = (Int(seconds) % 3_600) / 60
        if d > 0 { return "\(d)d \(h)h" }
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

private enum LiveIslandTheme {
    static let f1Red = Color(red: 1, green: 0.09, blue: 0.02)
    static let muted = Color.white.opacity(0.72)
    static let pillFill = Color.white.opacity(0.1)
}

private let raceDayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "d MMM yyyy"
    f.locale = Locale(identifier: "en_GB")
    return f
}()

private enum LiveFont {
    static func regular(_ size: CGFloat) -> Font { resolved("Orbitron-Regular", size: size) }
    static func bold(_ size: CGFloat) -> Font { resolved("Orbitron-Bold", size: size) }
    static func heavy(_ size: CGFloat) -> Font { resolved("Orbitron-ExtraBold", size: size) }

    private static func resolved(_ postScriptName: String, size: CGFloat) -> Font {
        if let ui = UIFont(name: postScriptName, size: size) {
            return Font(ui)
        }
        return .custom(postScriptName, size: size)
    }
}

struct NextRaceLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NextRaceLiveAttributes.self) { context in
            TimelineView(PeriodicTimelineSchedule(from: Date(), by: 60)) { timeline in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "flag.checkered.2.crossed")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(LiveIslandTheme.f1Red)
                        Text("NEXT RACE")
                            .font(LiveFont.bold(11))
                            .foregroundStyle(LiveIslandTheme.muted)
                            .tracking(1.2)
                    }
                    Text(context.attributes.raceName)
                        .font(LiveFont.heavy(18))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.88)
                    Text(context.attributes.circuitName)
                        .font(LiveFont.regular(13))
                        .foregroundStyle(LiveIslandTheme.muted)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                    HStack {
                        Text(raceDayFormatter.string(from: context.attributes.raceStart))
                            .font(LiveFont.bold(11))
                            .foregroundStyle(LiveIslandTheme.muted)
                        Spacer(minLength: 8)
                        Text(LiveCountdown.dhm(from: timeline.date, to: context.attributes.raceStart))
                            .font(LiveFont.heavy(26))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .activityBackgroundTint(Color(red: 0.06, green: 0.06, blue: 0.08))
            .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LiveIslandTheme.pillFill)
                                .frame(width: 44, height: 44)
                            Image(systemName: "flag.checkered.2.crossed")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(LiveIslandTheme.f1Red)
                        }
                        Text("NEXT RACE")
                            .font(LiveFont.bold(9))
                            .foregroundStyle(LiveIslandTheme.muted)
                            .tracking(1.4)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.leading, 14)
                    .padding(.top, 2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TimelineView(PeriodicTimelineSchedule(from: Date(), by: 60)) { timeline in
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(raceDayFormatter.string(from: context.attributes.raceStart))
                                .font(LiveFont.bold(10))
                                .foregroundStyle(LiveIslandTheme.muted)
                            Text(LiveCountdown.dhm(from: timeline.date, to: context.attributes.raceStart))
                                .font(LiveFont.heavy(22))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(2)
                                .minimumScaleFactor(0.75)
                        }
                        .frame(maxHeight: .infinity, alignment: .top)
                        .padding(.trailing, 14)
                        .padding(.top, 2)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 5) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        LiveIslandTheme.f1Red.opacity(0.95),
                                        LiveIslandTheme.f1Red.opacity(0.15),
                                        Color.clear,
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2)
                            .padding(.bottom, 2)
                        Text(context.attributes.raceName)
                            .font(LiveFont.bold(15))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(context.attributes.circuitName)
                            .font(LiveFont.regular(12))
                            .foregroundStyle(LiveIslandTheme.muted)
                            .lineLimit(2)
                            .minimumScaleFactor(0.88)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 6)
                    .padding(.bottom, 10)
                }
            } compactLeading: {
                ZStack {
                    Circle()
                        .fill(LiveIslandTheme.pillFill)
                        .frame(width: 22, height: 22)
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(LiveIslandTheme.f1Red)
                }
            } compactTrailing: {
                TimelineView(PeriodicTimelineSchedule(from: Date(), by: 60)) { timeline in
                    Text(LiveCountdown.dhmCompact(from: timeline.date, to: context.attributes.raceStart))
                        .font(LiveFont.bold(12))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
            } minimal: {
                Image(systemName: "flag.checkered.2.crossed")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LiveIslandTheme.f1Red)
            }
        }
    }
}
