import SwiftUI
import WidgetKit

@main
struct F1DashboardWidgetBundle: WidgetBundle {
    init() {
        _ = WidgetFontBootstrap.once
    }

    var body: some Widget {
        NextRaceTimelineWidget()
        NextRaceLiveActivityWidget()
    }
}
