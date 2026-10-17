/// Represents the operating mode of the AC unit.
enum AcMode {
  auto('Auto', '❄️🔥'),
  cool('Cool', '❄️'),
  dry('Dry', '💧'),
  fan('Fan', '🌀');

  const AcMode(this.label, this.icon);
  final String label;
  final String icon;
}

/// Represents the fan speed setting.
enum FanSpeed {
  auto('Auto'),
  low('Low'),
  medium('Medium'),
  high('High');

  const FanSpeed(this.label);
  final String label;
}

/// Immutable snapshot of the AC's current state.
class AcState {
  final bool isOn;
  final int temperature; // 18–32 °C
  final AcMode mode;
  final FanSpeed fanSpeed;
  final bool swingEnabled;
  final int flapPosition; // 1 to 6 (1 = 15° horizontal, 6 = 90° downward)

  const AcState({
    this.isOn = false,
    this.temperature = 24,
    this.mode = AcMode.cool,
    this.fanSpeed = FanSpeed.auto,
    this.swingEnabled = false,
    this.flapPosition = 3,
  });

  /// Flap angle in degrees corresponding to flapPosition (1–6).
  int get flapAngleDegrees => switch (flapPosition) {
    1 => 15,
    2 => 30,
    3 => 45,
    4 => 60,
    5 => 75,
    _ => 90,
  };

  /// Human-readable label for the flap position.
  String get flapDescription => switch (flapPosition) {
    1 => '15° High',
    2 => '30° Up',
    3 => '45° Mid',
    4 => '60° Down',
    5 => '75° Low',
    _ => '90° Floor',
  };

  AcState copyWith({
    bool? isOn,
    int? temperature,
    AcMode? mode,
    FanSpeed? fanSpeed,
    bool? swingEnabled,
    int? flapPosition,
  }) {
    return AcState(
      isOn: isOn ?? this.isOn,
      temperature: temperature ?? this.temperature,
      mode: mode ?? this.mode,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      swingEnabled: swingEnabled ?? this.swingEnabled,
      flapPosition: flapPosition ?? this.flapPosition,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcState &&
          runtimeType == other.runtimeType &&
          isOn == other.isOn &&
          temperature == other.temperature &&
          mode == other.mode &&
          fanSpeed == other.fanSpeed &&
          swingEnabled == other.swingEnabled &&
          flapPosition == other.flapPosition;

  @override
  int get hashCode => Object.hash(
        isOn,
        temperature,
        mode,
        fanSpeed,
        swingEnabled,
        flapPosition,
      );

  @override
  String toString() =>
      'AcState(on=$isOn, temp=$temperature°C, mode=$mode, fan=$fanSpeed, swing=$swingEnabled, flap=$flapPosition)';
}
