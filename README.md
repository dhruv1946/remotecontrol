# O General AC Remote Control

A modern, high-contrast monochrome Flutter application for controlling an O General air conditioner via Firebase Realtime Database and an ESP8266 / NodeMCU IR transceiver.

---

## Features

- **Monochrome Dark Aesthetics**: Pure black-and-white minimalist design with glowing indicators and tactile feedback.
- **Full AC Controls**:
  - **Power**: Instant toggle with animated visual state and live power status badge.
  - **Temperature Stepper**: Precision 18°C – 32°C stepper with interactive range pip indicators and dynamic comfort status (`VERY COOL`, `COMFORTABLE`, etc.).
  - **Mode Selector**: Cool, Auto, Dry, and Fan with high-contrast active cards.
  - **Fan Speed**: Segmented speed controls (Auto, Low, Medium, High) with animated spinning fan indicators.
  - **Airflow & Louver Controls**:
    - **SWING**: Continuous vertical oscillation toggle with animated vane icon.
    - **SET**: 6-step vertical flap angle control (15°, 30°, 45°, 60°, 75°, 90°) with custom canvas louver graphics and step progression pips.
- **Dual-Node Realtime Architecture**:
  - **Optimistic Updates**: Immediate UI reaction with automatic syncing status indicator while awaiting hardware confirmation.
  - **Firebase Realtime Database**: Synchronizes desired state (`/desiredState`) and hardware confirmation (`/confirmedState`).
  - **ESP8266 / NodeMCU Integration**: Bi-directional IR transmission and reception via `IRremoteESP8266` (Fujitsu ARRAH2E protocol).
  - **Anonymous Firebase Authentication**: Built-in authentication handshake ensures secure database access out of the box.

---

## Architecture Overview

```
┌──────────────────┐               ┌───────────────────────────────┐
│  Flutter Client  │ ──(Write)───> │  RTDB: /desiredState          │
│ (Web / Android)  │ <──(Listen)── │  RTDB: /confirmedState        │
└──────────────────┘               └───────────────────────────────┘
                                                  │
                                          (Listen & Confirm)
                                                  │
                                                  ▼
                                   ┌───────────────────────────────┐
                                   │       NodeMCU (ESP8266)       │
                                   │  - IR Transmitter (LED / D2)  │
                                   │  - IR Receiver   (KY-022 / D5)│
                                   └───────────────────────────────┘
                                                  │ (IR Signals)
                                                  ▼
                                   ┌───────────────────────────────┐
                                   │     O General Air Conditioner │
                                   └───────────────────────────────┘
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24.0 or newer)
- Target: Web (Chrome, Brave, Edge) or Android (API 21+)
- A Firebase project with **Realtime Database** and **Anonymous Authentication** enabled.

### Setup Firebase Configuration

Because API keys and configuration files are excluded from version control for security, generate or place your credentials before running:

1. **Android**: Place your `google-services.json` into `android/app/`.
2. **FlutterFire**: Run `flutterfire configure` to generate `lib/firebase_options.dart`.

---

## Running the App

### Web (Chrome / Brave)

To run the application in **Brave** (or another Chromium-based browser):

```powershell
# Set the browser executable path (PowerShell)
$env:CHROME_EXECUTABLE = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"

# Launch in Brave with Hot Reload & Debugging
flutter run -d chrome
```

For standard Chrome:
```bash
flutter run -d chrome
```

### Android (Device / Emulator)

```bash
flutter run -d <device-id>
```

---

## Building Releases

### Android APK

To generate a standalone release APK:

```bash
flutter build apk --release
```

Output location:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Web Release

```bash
flutter build web --release
```

---

## Code Quality & Tests

Run test suites and static analysis:

```bash
# Run unit and widget tests
flutter test

# Run static analysis
flutter analyze
```
