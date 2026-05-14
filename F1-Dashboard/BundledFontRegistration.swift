import CoreText
import Foundation
import UIKit

/// Registers every `*.ttf` under `Fonts/` in the app bundle. `UIAppFonts` should already list them;
/// this runs first and fixes cases where the merged Info.plist does not load custom fonts reliably.
enum BundledFontRegistration {
    static func registerAllTTFontsInFontsFolder() {
        let folder = "Fonts"
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: folder) else {
            #if DEBUG
            print("BundledFontRegistration: no URLs for ttf in subdirectory \(folder)")
            #endif
            return
        }
        for url in urls {
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                #if DEBUG
                if let err = error?.takeRetainedValue() {
                    print("BundledFontRegistration: \(url.lastPathComponent) — \(err)")
                }
                #endif
            }
        }
        #if DEBUG
        let probe = UIFont(name: "Orbitron-Bold", size: 12)
        print("BundledFontRegistration: Orbitron-Bold probe =", probe != nil ? "OK" : "FAILED")
        #endif
    }
}
