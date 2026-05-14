//
//  Typography.swift
//  F1-Dashboard
//
//  Orbitron (OFL) — static TTFs in Fonts/
//

import SwiftUI
import UIKit

enum AppFont {
    /// PostScript names match Google Fonts static filenames (e.g. `Orbitron-Bold`).
    static func orbitron(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(postScriptName(for: weight), size: size)
    }

    private static func postScriptName(for weight: Font.Weight) -> String {
        switch weight {
        case .black:
            return "Orbitron-Black"
        case .heavy:
            return "Orbitron-ExtraBold"
        case .bold:
            return "Orbitron-Bold"
        case .semibold:
            return "Orbitron-SemiBold"
        case .medium:
            return "Orbitron-Medium"
        default:
            return "Orbitron-Regular"
        }
    }
}

extension UIFont {
    static func f1Orbitron(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let ps: String
        switch weight {
        case .heavy, .black:
            ps = "Orbitron-ExtraBold"
        case .bold, .semibold:
            ps = "Orbitron-Bold"
        case .medium:
            ps = "Orbitron-Medium"
        default:
            ps = "Orbitron-Regular"
        }
        return UIFont(name: ps, size: size) ?? .systemFont(ofSize: size, weight: weight)
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
