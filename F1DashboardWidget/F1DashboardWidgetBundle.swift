import SwiftUI
import WidgetKit

@main
struct F1DashboardWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextRaceTimelineWidget()
        NextRaceLiveActivityWidget()
    }
}
