//
//  Typography.swift
//  F1-Dashboard
//
//  Orbitron (OFL) — static TTFs in Fonts/, registered at launch via BundledFontRegistration.
//

import SwiftUI
import UIKit

enum AppFont {
    /// Uses `UIFont` first, then `Font(_:)` (UIKit bridge) so SwiftUI applies the loaded face.
    /// Avoid `.monospacedDigit()` on these texts — it often swaps digits to SF Mono.
    static func orbitron(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        for name in candidatePostScriptNames(for: weight) {
            if let ui = UIFont(name: name, size: size) {
                return Font(ui)
            }
        }
        return .system(size: size, weight: weight)
    }

    private static func candidatePostScriptNames(for weight: Font.Weight) -> [String] {
        let primary = postScriptName(for: weight)
        let fallbacks = fallbackPostScriptNames(for: weight)
        return [primary] + fallbacks.filter { $0 != primary }
    }

    private static func fallbackPostScriptNames(for weight: Font.Weight) -> [String] {
        if weight == .black {
            return ["Orbitron-ExtraBold", "Orbitron-Bold", "Orbitron-SemiBold", "Orbitron-Regular"]
        }
        if weight == .heavy {
            return ["Orbitron-Bold", "Orbitron-SemiBold", "Orbitron-Medium", "Orbitron-Regular"]
        }
        if weight == .bold {
            return ["Orbitron-SemiBold", "Orbitron-Medium", "Orbitron-Regular"]
        }
        if weight == .semibold {
            return ["Orbitron-Medium", "Orbitron-Bold", "Orbitron-Regular"]
        }
        if weight == .medium {
            return ["Orbitron-SemiBold", "Orbitron-Regular"]
        }
        if weight == .regular {
            return ["Orbitron-Medium", "Orbitron-Bold"]
        }
        return ["Orbitron-Regular"]
    }

    private static func postScriptName(for weight: Font.Weight) -> String {
        if weight == .black { return "Orbitron-Black" }
        if weight == .heavy { return "Orbitron-ExtraBold" }
        if weight == .bold { return "Orbitron-Bold" }
        if weight == .semibold { return "Orbitron-SemiBold" }
        if weight == .medium { return "Orbitron-Medium" }
        return "Orbitron-Regular"
    }
}

extension UIFont {
    static func f1Orbitron(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let candidates: [String]
        switch weight {
        case .black: candidates = ["Orbitron-Black", "Orbitron-ExtraBold", "Orbitron-Bold", "Orbitron-Regular"]
        case .heavy: candidates = ["Orbitron-ExtraBold", "Orbitron-Bold", "Orbitron-Regular"]
        case .bold: candidates = ["Orbitron-Bold", "Orbitron-SemiBold", "Orbitron-Regular"]
        case .semibold: candidates = ["Orbitron-SemiBold", "Orbitron-Medium", "Orbitron-Bold", "Orbitron-Regular"]
        case .medium: candidates = ["Orbitron-Medium", "Orbitron-Regular"]
        default: candidates = ["Orbitron-Regular"]
        }
        for name in candidates {
            if let f = UIFont(name: name, size: size) { return f }
        }
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
