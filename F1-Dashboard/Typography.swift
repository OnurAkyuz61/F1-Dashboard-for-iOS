//
//  Typography.swift
//  F1-Dashboard
//
//  Web-adjacent display styling (no bundled F1 font — wide/heavy system for a similar feel).
//

import SwiftUI

enum F1Typography {
    static let displayTracking: CGFloat = 1.4
    static let labelTracking: CGFloat = 0.8
    
    static func displayLarge() -> Font {
        .system(size: 32, weight: .heavy, design: .default)
    }
    
    static func displayMedium() -> Font {
        .system(size: 22, weight: .bold, design: .default)
    }
    
    static func sectionTitle() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }
}

extension View {
    func f1DisplayStyle(tracking: CGFloat = F1Typography.displayTracking) -> some View {
        self.tracking(tracking)
    }
}
