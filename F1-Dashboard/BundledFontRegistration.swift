import CoreText
import Foundation
import UIKit

/// Loads every Orbitron `.ttf` from the app bundle (several possible folder layouts).
/// Call once at launch before any UI that uses `AppFont.orbitron`.
enum BundledFontRegistration {
    private static let didRunLock = NSLock()
    private static var didRun = false

    static func registerAllTTFontsInFontsFolder() {
        didRunLock.lock()
        defer { didRunLock.unlock() }
        guard !didRun else { return }
        didRun = true

        let urls = Self.collectOrbitronFontURLs()
        #if DEBUG
        print("BundledFontRegistration: found \(urls.count) Orbitron font file(s)")
        #endif

        for url in urls {
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                #if DEBUG
                if let err = error?.takeRetainedValue() {
                    print("BundledFontRegistration: register failed \(url.lastPathComponent): \(err)")
                }
                #endif
            }
        }

        #if DEBUG
        let names = UIFont.fontNames(forFamilyName: "Orbitron")
        print("BundledFontRegistration: UIFont.fontNames(forFamilyName: \"Orbitron\") count =", names.count)
        if !names.isEmpty { print("BundledFontRegistration: faces:", names.joined(separator: ", ")) }
        let probeBold = UIFont(name: "Orbitron-Bold", size: 12) != nil
        let probeExtra = UIFont(name: "Orbitron-ExtraBold", size: 12) != nil
        print("BundledFontRegistration: UIFont Orbitron-Bold =", probeBold, "Orbitron-ExtraBold =", probeExtra)
        #endif
    }

    private static func collectOrbitronFontURLs() -> [URL] {
        var urls: [URL] = []
        let bundle = Bundle.main

        if let sub = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts") {
            urls.append(contentsOf: sub)
        }
        if let flat = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) {
            urls.append(contentsOf: flat.filter { $0.lastPathComponent.hasPrefix("Orbitron") })
        }

        let fontsDir = bundle.bundleURL.appendingPathComponent("Fonts", isDirectory: true)
        if FileManager.default.fileExists(atPath: fontsDir.path),
           let enumerator = FileManager.default.enumerator(at: fontsDir, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                guard fileURL.pathExtension.lowercased() == "ttf" else { continue }
                guard fileURL.lastPathComponent.hasPrefix("Orbitron") else { continue }
                urls.append(fileURL)
            }
        }

        var seen = Set<String>()
        return urls.filter { seen.insert($0.path).inserted }
    }
}
