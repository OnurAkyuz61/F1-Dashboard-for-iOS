import F1Core
import SwiftUI
import WidgetKit

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
        let entry = NextRaceEntry(date: Date(), payload: NextRaceWidgetPayload.load())
        let refresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct NextRaceTimelineWidget: Widget {
    var body: some Widget {
        StaticConfiguration(kind: "com.onurakyuz.F1-Dashboard.nextRace", provider: NextRaceTimelineProvider()) { entry in
            NextRaceWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(red: 0.04, green: 0.04, blue: 0.04)
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
                Text("\(p.raceName) · \(p.raceStart, style: .timer)")
            } else {
                Text("F1 Dashboard")
            }
        }
    }
    
    private var accessoryCircular: some View {
        ZStack {
            AccessoryWidgetBackground()
            if let p = entry.payload {
                VStack(spacing: 2) {
                    Text("R\(p.round)")
                        .font(.custom("Orbitron-Bold", size: 12))
                    Text(p.raceStart, style: .timer)
                        .font(.custom("Orbitron-Bold", size: 10))
                        .minimumScaleFactor(0.5)
                }
            } else {
                Image(systemName: "flag.checkered")
            }
        }
    }
    
    private var accessoryRectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let p = entry.payload {
                Text("R\(p.round) · \(p.raceName)")
                    .font(.custom("Orbitron-Bold", size: 12))
                    .lineLimit(1)
                Text(p.raceStart, style: .timer)
                    .font(.custom("Orbitron-Regular", size: 11))
            } else {
                Text("Open F1 Dashboard")
                    .font(.custom("Orbitron-Regular", size: 12))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    private var systemLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flag.checkered.2.crossed")
                    .foregroundStyle(.red)
                Text("NEXT RACE")
                    .font(.custom("Orbitron-Bold", size: 11))
                    .tracking(1.2)
                    .foregroundStyle(.secondary)
            }
            if let p = entry.payload {
                Text(p.raceName)
                    .font(.custom("Orbitron-ExtraBold", size: family == .systemSmall ? 16 : 20))
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
                Text(p.circuitName)
                    .font(.custom("Orbitron-Regular", size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(p.raceStart, style: .date)
                    .font(.custom("Orbitron-Regular", size: 11))
                    .foregroundStyle(.tertiary)
                Text(p.raceStart, style: .timer)
                    .font(.custom("Orbitron-Bold", size: family == .systemLarge ? 28 : 20))
                    .foregroundStyle(.red)
            } else {
                Text("Open the app to load schedule")
                    .font(.custom("Orbitron-Regular", size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}
