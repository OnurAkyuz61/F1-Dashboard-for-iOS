import CoreText
import Foundation

/// Registers bundled Orbitron variable font early (widget process). Plist `UIAppFonts` should list the same file; this is a safety net.
enum WidgetFontBootstrap {
    static let once: Void = {
        let base = "Orbitron-VF"
        let urls: [URL?] = [
            Bundle.main.url(forResource: base, withExtension: "ttf", subdirectory: "Fonts"),
            Bundle.main.url(forResource: base, withExtension: "ttf"),
        ]
        for case let url? in urls {
            var error: Unmanaged<CFError>?
            if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                break
            }
        }
        return ()
    }()
}
