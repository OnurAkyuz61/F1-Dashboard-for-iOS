//
//  F1_DashboardApp.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import SwiftUI

@main
struct F1_DashboardApp: App {
    init() {
        BundledFontRegistration.registerAllTTFontsInFontsFolder()
        UserDefaults.standard.register(defaults: [
            "raceRemindersEnabled": true,
            "liveActivitiesEnabled": true,
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
    }
}
