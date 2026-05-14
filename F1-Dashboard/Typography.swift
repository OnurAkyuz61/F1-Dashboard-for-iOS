//
//  Typography.swift
//  F1-Dashboard
//
//  Orbitron (OFL) — bundled TTFs in Fonts/
//

import SwiftUI

enum AppFont {
    private static let regular = "Orbitron-Regular"
    private static let bold = "Orbitron-Bold"
    private static let extraBold = "Orbitron-ExtraBold"
    
    static func orbitron(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .heavy, .black:
            name = extraBold
        case .bold, .semibold:
            name = bold
        default:
            name = regular
        }
        return .custom(name, size: size)
    }
}

enum F1Typography {
    static let displayTracking: CGFloat = 1.4
    static let labelTracking: CGFloat = 0.8
    
    static func displayLarge() -> Font {
        AppFont.orbitron(32, weight: .heavy)
    }
    
    static func displayMedium() -> Font {
        AppFont.orbitron(22, weight: .bold)
    }
    
    static func sectionTitle() -> Font {
        AppFont.orbitron(17, weight: .semibold)
    }
}

extension View {
    func f1DisplayStyle(tracking: CGFloat = F1Typography.displayTracking) -> some View {
        self.tracking(tracking)
    }
}
