<div align="center">
  <img src="F1-Dashboard/Assets.xcassets/AppIcon.appiconset/Icon-iOS-Dark-1024x1024@1x.png" alt="F1 Dashboard Logo" width="200" height="200">
  
  # F1 Dashboard for iOS
  
  **Formula 1 companion app — SwiftUI, widgets & Live Activities**
  
  [![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
  [![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)](https://developer.apple.com/xcode/swiftui/)
  [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

---

## Overview

**F1 Dashboard** is a native iOS app for following the current Formula 1 season: next race countdown on the home screen, driver and constructor standings, full race calendar with winners (where available), and a team grid. The UI is dark-first with F1 red accents, glass-style cards, and **Orbitron** as the primary typeface (bundled static fonts).

### Highlights

- **Home** — Next race hero card: countdown shows **days · hours · minutes · seconds** while there is at least one full day left; under 24 hours from race day it switches to **hours · minutes · seconds**. Top drivers preview, circuit snippet, wide laps/length row.
- **Standings** — Drivers / constructors segmented control; flowing driver name (given + family name wrap as one line of text).
- **Races** — Calendar with upcoming vs completed styling; winner line when results exist.
- **Teams** — Two-column team cards with constructor colours.
- **About** — Links to the web dashboard and personal site, Jolpi/Ergast attribution, toggles for **race notifications** and **Live Activities**, and **Open iOS Settings** for permissions.
- **Splash** — Short branded intro on cold launch.
- **Home Screen Widget** (`F1DashboardWidget`) — Next race + pit-style countdown (sizes small / medium / large + lock screen accessories). Data via **App Group** shared defaults.
- **Live Activities** — Next-race countdown on Lock Screen / Dynamic Island when enabled.
- **Local notifications** — Optional reminders before the race (when permission granted).

---

## Architecture

| Area | Description |
|------|-------------|
| **App target** | `F1-Dashboard/` — SwiftUI views, `F1DataService`, `NotificationManager`, `WidgetDataStore`, `NextRaceLiveActivityManager`, `BundledFontRegistration`, fonts under `Fonts/`. |
| **SPM** | `F1Core/` — `NextRaceWidgetPayload`, `NextRaceLiveAttributes` (shared with the widget extension). |
| **Widget extension** | `F1DashboardWidget/` — timeline widget + Live Activity configuration; `WidgetBundledFontRegistration`; Info via `F1DashboardWidgetExtension-Info.plist` at repo root. |
| **Project** | `F1-Dashboard.xcodeproj` — embeds the widget extension; both targets use the same **marketing version** for `CFBundleShortVersionString`. |

### Repository layout (abridged)

```
F1-Dashboard/
├── Fonts/                    # Orbitron TTFs (UIAppFonts + runtime registration)
├── Services/
│   ├── F1DataService.swift
│   ├── NotificationManager.swift
│   ├── WidgetDataStore.swift
│   └── NextRaceLiveActivityManager.swift
├── Views/
│   ├── HomeView.swift
│   ├── StandingsView.swift
│   ├── RacesView.swift
│   ├── TeamsView.swift
│   ├── AboutView.swift
│   ├── RootView.swift
│   ├── SplashView.swift
│   └── …
├── Typography.swift
├── BundledFontRegistration.swift
└── ContentView.swift         # Tab bar: Home, Standings, Races, Teams, About

F1Core/
└── Sources/F1Core/

F1DashboardWidget/
├── NextRaceTimelineWidget.swift
├── NextRaceLiveActivityWidget.swift
└── Fonts/
```

---

## Data source

HTTP JSON is loaded from the **Jolpi Ergast mirror**:

- Base URL: `https://api.jolpi.ca/ergast/f1`
- Typical paths include `current.json`, `current/driverStandings.json`, `current/constructorStandings.json`, and `current/results.json` (for race winners), following the Ergast-style API.

Requests send `Accept: application/json`. If the network fails, the app can fall back to a **built-in race** / mock-style behaviour so the UI still runs.

**Attribution** — Jolpi/Ergast and F1 trademark disclaimer appear in-app (About / footers). This app is **not** affiliated with Formula 1.

---

## Requirements & setup

1. **Xcode** — Open `F1-Dashboard.xcodeproj`.
2. **Deployment target** — Set in Xcode (`IPHONEOS_DEPLOYMENT_TARGET` in the project); align with your device / simulator SDK.
3. **Signing & capabilities**
   - App Group **`group.onurakyuz.F1-Dashboard`** on the **app** and **widget** targets if you change the identifier, keep both in sync.
   - **Push Notifications** / notification permission copy is in `Info.plist` where applicable.
4. **Build & run** — Select the `F1-Dashboard` scheme, run on a simulator or device.

### Bundled assets

- F1 header image and app icon set under `Assets.xcassets`.
- **Orbitron** font files listed in `Info.plist` (`UIAppFonts`) and registered at launch via `BundledFontRegistration` (SwiftUI uses `Font` bridged from `UIFont` for reliable application of custom faces).

---

## Typography & UI notes

- **Orbitron** — Regular / Medium / SemiBold / Bold / ExtraBold / Black for weights used in `Typography.swift` / views.
- **Custom fonts** — Avoid chaining `.monospacedDigit()` on Orbitron countdown text; it tends to substitute system monospaced digits.

---

## Widget & Live Activity

- After a successful load, **`WidgetDataStore`** writes `NextRaceWidgetPayload` into the App Group; the widget timeline reads it.
- **Live Activities** are started/ended from the app when the user enables them and a future race exists (`NextRaceLiveActivityManager`).

---

## Screenshots

Optional images under `Screenshots/` (e.g. `Home.png`, `Standings.png`, …). Add or update paths here when you export new captures.

---

## Contributing

Pull requests are welcome. For larger changes, open an issue first. Keep edits focused, match existing SwiftUI style, and preserve the dark F1 dashboard look unless intentionally redesigning.

---

## License

MIT — see [LICENSE](LICENSE).

---

## Author

**Onur Akyüz**

- GitHub: [@OnurAkyuz61](https://github.com/OnurAkyuz61)
- Repository: [F1-Dashboard-for-iOS](https://github.com/OnurAkyuz61/F1-Dashboard-for-iOS)

---

## Disclaimer

Unofficial F1 fan project. Formula 1 marks and logos are trademarks of Formula One Licensing BV. Not affiliated with or endorsed by Formula 1.

---

## Possible next steps

- Live session timing (FP / quali / race) and lap charts  
- Richer driver / team detail screens  
- iPad-adaptive layouts  
- Watch app or additional widget families  

---

<div align="center">
  <p>Built with SwiftUI</p>
</div>
