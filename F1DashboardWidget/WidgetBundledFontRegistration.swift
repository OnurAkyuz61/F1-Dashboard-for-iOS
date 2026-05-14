import CoreText
import Foundation
import WidgetKit

/// Widget process: register Orbitron TTFs (bundle layout may omit plist-only loading).
enum WidgetBundledFontRegistration {
    private static let once: Void = {
        let bundle = Bundle.main
        var urls: [URL] = []
        if let sub = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts") {
            urls.append(contentsOf: sub)
        }
        if let flat = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) {
            urls.append(contentsOf: flat.filter { $0.lastPathComponent.hasPrefix("Orbitron") })
        }
        let fontsDir = bundle.bundleURL.appendingPathComponent("Fonts", isDirectory: true)
        if FileManager.default.fileExists(atPath: fontsDir.path),
           let enumerator = FileManager.default.enumerator(at: fontsDir, includingPropertiesForKeys: nil) {
            for case let u as URL in enumerator where u.pathExtension.lowercased() == "ttf" && u.lastPathComponent.hasPrefix("Orbitron") {
                urls.append(u)
            }
        }
        var seen = Set<String>()
        for url in urls where seen.insert(url.path).inserted {
            var err: Unmanaged<CFError>?
            _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &err)
        }
        return ()
    }()

    static func ensureRegistered() {
        _ = once
    }
}
