//
//  Typography.swift
//  F1-Dashboard
//
//  Orbitron variable font (OFL) — bundled as Fonts/Orbitron-VF.ttf
//

import SwiftUI
import UIKit

enum AppFont {
    /// Google Fonts variable build registers as family **Orbitron**; use `.weight(...)` for axes.
    private static let family = "Orbitron"

    static func orbitron(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(family, size: size).weight(weight)
    }
}

extension UIFont {
    /// Orbitron from the bundled variable font (family name `Orbitron`).
    static func f1Orbitron(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let traits: [UIFontDescriptor.TraitKey: Any] = [.weight: weight]
        let attributes: [UIFontDescriptor.AttributeName: Any] = [
            .family: "Orbitron",
            .traits: traits,
        ]
        let desc = UIFontDescriptor(fontAttributes: attributes)
        let font = UIFont(descriptor: desc, size: size)
        let name = font.fontName.lowercased()
        if name.contains("orbitron") { return font }
        return .systemFont(ofSize: size, weight: weight)
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
