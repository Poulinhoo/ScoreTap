# ScoreTap

A watchOS scoring app for tennis and padel, designed to track match scores directly from your Apple Watch during play.

## Features

**Match Mode** — Full scoring with sets, games, and points
- Standard tennis scoring: 0 / 15 / 30 / 40 / Advantage
- Automatic game, set, and tiebreak management (triggered at 6-6)
- Best-of-3 sets format (first to 2 sets wins)
- Winner announcement at match end
- Undo support to correct scoring mistakes

**Tiebreak Mode** — Quick point-by-point scoring
- Configurable target points: 5, 7, 10, 12, 15, or 20
- Win condition: first to reach target with a 2-point lead
- Available standalone or embedded within a full match

Both modes include haptic and audio feedback via WatchKit.

## Requirements

- macOS with Xcode 15+
- watchOS 10.0+ on the target Apple Watch
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) to (re)generate the Xcode project

## Install XcodeGen

```bash
brew install xcodegen
```

## Build

### 1. Generate the Xcode project

The `.xcodeproj` is not committed to the repo. Generate it from `project.yml`:

```bash
cd /path/to/ScoreTap
xcodegen generate
```

This creates `ScoreTap.xcodeproj` in the project root.

### 2. Open in Xcode

```bash
open ScoreTap.xcodeproj
```

### 3. Configure signing

In Xcode, select the **ScoreTap** target → **Signing & Capabilities** tab:
- Check **Automatically manage signing**
- Select your **Team** (Apple Developer account)

### 4. Run on simulator

Select an Apple Watch simulator (e.g. *Apple Watch Series 9 - 45mm*) in the scheme bar, then press `Cmd+R`.

### 5. Run on a physical Apple Watch

1. Pair your Apple Watch with Xcode via **Window → Devices and Simulators**
2. Select the watch in the scheme bar
3. Press `Cmd+R` — Xcode will install the app directly on the watch

> **Note:** Deploying to a physical device requires an Apple Developer account (free or paid). With a free account, the provisioning profile expires after 7 days.

## Project structure

```
ScoreTap/
├── project.yml                    # XcodeGen configuration
└── ScoreTap Watch App/
    ├── ScoreTapApp.swift          # App entry point
    ├── ContentView.swift          # Home screen (mode selection)
    ├── MatchView.swift            # Match mode UI
    ├── MatchViewModel.swift       # Match scoring logic
    ├── TiebreakView.swift         # Tiebreak mode UI
    ├── TiebreakViewModel.swift    # Tiebreak logic
    └── Assets.xcassets/           # Icons and colors
```

## Tech stack

| | |
|---|---|
| Language | Swift 5 |
| UI | SwiftUI |
| Platform | watchOS 10+ |
| Architecture | MVVM |
| Dependencies | None |
| Build tool | XcodeGen |
| Bundle ID | `com.poulinhoo.ScoreTap` |
