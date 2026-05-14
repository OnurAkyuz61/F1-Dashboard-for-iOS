import SwiftUI
import WidgetKit

@main
struct F1DashboardWidgetBundle: WidgetBundle {
    init() {
        WidgetBundledFontRegistration.ensureRegistered()
    }

    var body: some Widget {
        NextRaceTimelineWidget()
        NextRaceLiveActivityWidget()
    }
}
