import F1Core
import SwiftUI
import WidgetKit

// MARK: - Styling

private enum WFont {
    static func regular(_ size: CGFloat) -> Font { .custom("Orbitron-Regular", size: size) }
    static func bold(_ size: CGFloat) -> Font { .custom("Orbitron-Bold", size: size) }
    static func heavy(_ size: CGFloat) -> Font { .custom("Orbitron-ExtraBold", size: size) }
}

private enum WCountdown {
    /// e.g. `10d 7h 1m`, `7h 1m`, `45m`
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

private let widgetBackground = Color(red: 0.06, green: 0.06, blue: 0.07)

// MARK: - Entry & Provider

struct NextRaceEntry: TimelineEntry {
    let date: Date
    let payload: NextRaceWidgetPayload?
}

struct NextRaceTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextRaceEntry {
        NextRaceEntry(
            date: Date(),
            payload: NextRaceWidgetPayload(
                raceName: "Canadian Grand Prix",
                circuitName: "Circuit Gilles Villeneuve",
                round: "5",
                season: "2026",
                raceStart: Date().addingTimeInterval(3600)
            )
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (NextRaceEntry) -> Void) {
        completion(NextRaceEntry(date: Date(), payload: NextRaceWidgetPayload.load()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NextRaceEntry>) -> Void) {
        let now = Date()
        let entry = NextRaceEntry(date: now, payload: NextRaceWidgetPayload.load())
        let refresh = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now.addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct NextRaceTimelineWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "com.onurakyuz.F1-Dashboard.nextRace", provider: NextRaceTimelineProvider()) { entry in
            NextRaceWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    widgetBackground
                }
        }
        .configurationDisplayName("Next race")
        .description("Countdown to the next Grand Prix from F1 Dashboard.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}

// MARK: - Entry view

struct NextRaceWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: NextRaceEntry
    
    var body: some View {
        switch family {
        case .accessoryInline:
            accessoryInline
        case .accessoryCircular:
            accessoryCircular
        case .accessoryRectangular:
            accessoryRectangular
        default:
            systemLayout
        }
    }
    
    private var accessoryInline: some View {
        Group {
            if let p = entry.payload {
                Text("\(p.raceName) · \(WCountdown.dhm(from: entry.date, to: p.raceStart))")
                    .font(WFont.bold(12))
                    .foregroundStyle(.white)
            } else {
                Text("F1 Dashboard")
                    .font(WFont.regular(12))
                    .foregroundStyle(.white)
            }
        }
    }
    
    private var accessoryCircular: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let p = entry.payload {
                TimelineView(PeriodicTimelineSchedule(from: entry.date, by: 60)) { ctx in
                    VStack(spacing: 2) {
                        Text("R\(p.round)")
                            .font(WFont.bold(11))
                            .foregroundStyle(.white)
                        Text(WCountdown.dhm(from: ctx.date, to: p.raceStart))
                            .font(WFont.bold(9))
                            .foregroundStyle(.white)
                            .minimumScaleFactor(0.45)
                            .lineLimit(1)
                    }
                }
            } else {
                Image(systemName: "flag.checkered")
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }
    
    private var accessoryRectangular: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let p = entry.payload {
                TimelineView(PeriodicTimelineSchedule(from: entry.date, by: 60)) { ctx in
                    VStack(alignment: .leading, spacing: 3) {
                        Text("R\(p.round) · \(p.raceName)")
                            .font(WFont.bold(12))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(WCountdown.dhm(from: ctx.date, to: p.raceStart))
                            .font(WFont.regular(11))
                            .foregroundStyle(.white.opacity(0.92))
                    }
                }
            } else {
                Text("Open F1 Dashboard")
                    .font(WFont.regular(12))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    private var systemLayout: some View {
        Group {
            if let p = entry.payload {
                TimelineView(PeriodicTimelineSchedule(from: entry.date, by: 60)) { ctx in
                    systemCard(payload: p, now: ctx.date, family: family)
                }
            } else {
                emptyState
            }
        }
    }
    
    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("F1 DASHBOARD")
                .font(WFont.bold(12))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.9))
            Text("Open the app to load the calendar.")
                .font(WFont.regular(13))
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
    }
    
    @ViewBuilder
    private func systemCard(payload: NextRaceWidgetPayload, now: Date, family: WidgetFamily) -> some View {
        let isSmall = family == .systemSmall
        let isLarge = family == .systemLarge
        let countdown = WCountdown.dhm(from: now, to: payload.raceStart)
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "flag.checkered.2.crossed")
                    .font(.system(size: isSmall ? 13 : 15, weight: .semibold))
                    .foregroundStyle(Color(red: 1, green: 0.09, blue: 0.02))
                Text("NEXT RACE")
                    .font(WFont.bold(isSmall ? 10 : 11))
                    .tracking(1.6)
                    .foregroundStyle(.white.opacity(0.88))
                Spacer(minLength: 0)
                Text("R\(payload.round)")
                    .font(WFont.bold(10))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
            }
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1, green: 0.09, blue: 0.02).opacity(0.85),
                            Color(red: 1, green: 0.09, blue: 0.02).opacity(0.15),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 2)
                .padding(.top, 8)
                .padding(.bottom, isSmall ? 10 : 12)
            
            Text(payload.raceName)
                .font(WFont.heavy(isSmall ? 15 : (isLarge ? 22 : 18)))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.75)
                .lineLimit(isLarge ? 3 : 2)
                .shadow(color: .black.opacity(0.35), radius: 1, x: 0, y: 1)
            
            Text(payload.circuitName)
                .font(WFont.regular(isSmall ? 11 : 12))
                .foregroundStyle(.white.opacity(0.78))
                .lineLimit(2)
                .padding(.top, 4)
            
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                Text(Self.raceDayString(payload.raceStart))
                    .font(WFont.regular(11))
                    .foregroundStyle(.white.opacity(0.72))
            }
            .padding(.top, 8)
            
            Spacer(minLength: 6)
            
            HStack(alignment: .lastTextBaseline, spacing: 0) {
                Text(countdown)
                    .font(WFont.heavy(isLarge ? 30 : (isSmall ? 22 : 26)))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .padding(.top, 4)
            .padding(.horizontal, 12)
            .padding(.vertical, isSmall ? 8 : 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            )
        }
        .padding(isSmall ? 12 : 14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_GB")
        f.dateFormat = "d MMM yyyy"
        return f
    }()
    
    private static func raceDayString(_ date: Date) -> String {
        dayFormatter.string(from: date)
    }
}
