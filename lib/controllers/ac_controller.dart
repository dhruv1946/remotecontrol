import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/ac_state_repository.dart';
import '../models/ac_state.dart';

/// ChangeNotifier that listens to the repository stream and exposes
/// the latest [AcState] to the widget tree via Provider.
///
/// All user actions are forwarded to the repository; the UI only
/// rebuilds when the repository emits a new state (whether from the
/// user's own action or an external / simulated change).
class AcController extends ChangeNotifier {
  AcController(this._repository) {
    _state = _repository.currentState;
    _subscription = _repository.stateStream.listen(_onStateChanged);
  }

  final AcStateRepository _repository;
  late AcState _state;
  StreamSubscription<AcState>? _subscription;

  /// Whether an action is currently in flight (for loading indicators).
  bool _busy = false;

  AcState get state => _state;
  bool get busy => _busy;

  // ── Convenience getters for the UI ────────────────────────────────

  bool get isOn => _state.isOn;
  int get temperature => _state.temperature;
  AcMode get mode => _state.mode;
  FanSpeed get fanSpeed => _state.fanSpeed;
  bool get swingEnabled => _state.swingEnabled;
  int get flapPosition => _state.flapPosition;
  int get flapAngleDegrees => _state.flapAngleDegrees;
  String get flapDescription => _state.flapDescription;

  // ── Actions ───────────────────────────────────────────────────────

  Future<void> togglePower() => _exec(() => _repository.togglePower());
  Future<void> incrementTemp() => _exec(() => _repository.setTemperature(_state.temperature + 1));
  Future<void> decrementTemp() => _exec(() => _repository.setTemperature(_state.temperature - 1));
  Future<void> setMode(AcMode m) => _exec(() => _repository.setMode(m));
  Future<void> setFanSpeed(FanSpeed s) => _exec(() => _repository.setFanSpeed(s));
  Future<void> toggleSwing() => _exec(() => _repository.toggleSwing());
  Future<void> setFlapPosition(int pos) => _exec(() => _repository.setFlapPosition(pos));
  Future<void> cycleFlapPosition() => _exec(() => _repository.cycleFlapPosition());

  // ── Internals ─────────────────────────────────────────────────────

  Future<void> _exec(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _onStateChanged(AcState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
