import 'dart:async';
import '../models/ac_state.dart';

/// Abstract interface for AC state persistence and real-time sync.
///
/// Implementations may back this with Firebase Realtime Database,
/// Firestore, local storage, or an in-memory mock.
///
/// The [stateStream] provides a continuous stream of [AcState] snapshots,
/// allowing the UI to react to changes from any source (user interaction,
/// remote device, or simulated changes).
abstract class AcStateRepository {
  /// A stream of [AcState] snapshots. The UI subscribes to this to stay
  /// in sync with the latest state, regardless of where the change
  /// originated.
  Stream<AcState> get stateStream;

  /// Returns the current state synchronously.
  /// This is useful for initialisation before the stream emits.
  AcState get currentState;

  /// Sends a full state update to the underlying data source.
  /// The implementation is responsible for persisting and broadcasting
  /// the change through [stateStream].
  Future<void> updateState(AcState newState);

  /// Convenience methods that read the current state, apply a delta,
  /// and call [updateState]. Subclasses may override for optimised
  /// partial writes.

  Future<void> togglePower() =>
      updateState(currentState.copyWith(isOn: !currentState.isOn));

  Future<void> setTemperature(int temp) {
    final clamped = temp.clamp(18, 32);
    return updateState(currentState.copyWith(temperature: clamped));
  }

  Future<void> setMode(AcMode mode) =>
      updateState(currentState.copyWith(mode: mode));

  Future<void> setFanSpeed(FanSpeed fanSpeed) =>
      updateState(currentState.copyWith(fanSpeed: fanSpeed));

  Future<void> toggleSwing() =>
      updateState(currentState.copyWith(swingEnabled: !currentState.swingEnabled));

  Future<void> setFlapPosition(int position) {
    final clamped = position.clamp(1, 6);
    // Setting fixed flap position turns off continuous swing (O General behavior)
    return updateState(currentState.copyWith(
      flapPosition: clamped,
      swingEnabled: false,
    ));
  }

  Future<void> cycleFlapPosition() {
    final next = (currentState.flapPosition % 6) + 1;
    return setFlapPosition(next);
  }

  /// Clean up resources (timers, listeners, etc.).
  void dispose();
}
