# O General AC Remote Control

A modern, high-contrast monochrome Flutter application for controlling an O General air conditioner.

## Features

- **Monochrome Dark Aesthetics**: Pure black and white styling with high-contrast active states.
- **Full AC Controls**:
  - **Power**: Instant toggle with animated visual state.
  - **Temperature Stepper**: Precision 16°C – 30°C stepper with live range pip indicators and temperature status.
  - **Mode Selector**: Auto, Cool, Dry, and Fan with high-contrast active feedback.
  - **Fan Speed**: Segmented speeds (Auto, Low, Medium, High) with animated rotating fans.
  - **Airflow & Louver Controls**:
    - **SWING**: Auto vertical oscillation toggle with animated vane icon.
    - **SET**: 6-step vertical flap angle control (15°, 30°, 45°, 60°, 75°, 90°) with custom-rendered louver graphics and step progress indicators.
- **Clean Architecture**:
  - Abstract `AcStateRepository` interface decoupling the UI from data layers.
  - Ready for Firebase Realtime Database / Firestore backend drop-in.
  - Responsive state management using `Provider` (`ChangeNotifier`).

## Getting Started

### Prerequisites

- Flutter SDK (3.24+ recommended)
- Chrome or Brave browser / Android Device / Emulator

### Running Locally

```bash
# Set Chromium browser executable if using Brave
$env:CHROME_EXECUTABLE = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"

# Run in browser
flutter run -d chrome

# Or run release web build
flutter run -d chrome --release
```

### Testing

```bash
flutter test
flutter analyze
```
