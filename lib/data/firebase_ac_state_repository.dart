import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/ac_state.dart';
import 'ac_state_repository.dart';

/// Firebase Realtime Database implementation of [AcStateRepository].
///
/// Follows the dual-node architecture:
/// - Writes user-requested changes to `/desiredState`
///   Structure: `{power, temp, mode, fanSpeed, swing, flapPosition, timestamp}`
/// - Listens in real-time to `/confirmedState` via [onValue]
///   Structure: `{power, temp, mode, fanSpeed, swing, flapPosition, lastUpdatedBy, timestamp}`
///
/// A loading/syncing state ([isSyncing]) is maintained while waiting for
/// `/confirmedState` to reflect `/desiredState` after a user-initiated change.
class FirebaseAcStateRepository extends AcStateRepository {
  FirebaseAcStateRepository({
    FirebaseDatabase? database,
    String? databaseURL,
    AcState initialState = const AcState(),
    this.syncTimeout = const Duration(seconds: 15),
  })  : _currentState = initialState,
        _database = database ??
            FirebaseDatabase.instanceFor(
              app: Firebase.app(),
              databaseURL: databaseURL ??
                  Firebase.app().options.databaseURL ??
                  'https://smart-remote-controller-17fc1-default-rtdb.asia-southeast1.firebasedatabase.app',
            ) {
    _desiredRef = _database.ref('desiredState');
    _confirmedRef = _database.ref('confirmedState');

    _stateController = StreamController<AcState>.broadcast();
    _syncingController = StreamController<bool>.broadcast();

    // Emit initial values immediately to subscribers
    _stateController.add(_currentState);
    _syncingController.add(false);

    // Start listening to /confirmedState in real-time
    _confirmedSubscription =
        _confirmedRef.onValue.listen(_handleConfirmedStateEvent);
  }

  final FirebaseDatabase _database;
  late final DatabaseReference _desiredRef;
  late final DatabaseReference _confirmedRef;

  late final StreamController<AcState> _stateController;
  late final StreamController<bool> _syncingController;
  StreamSubscription<DatabaseEvent>? _confirmedSubscription;

  /// Timeout duration after which syncing status will reset to false
  /// if the physical device does not report a matching /confirmedState.
  final Duration syncTimeout;
  Timer? _syncTimeoutTimer;

  AcState _currentState;
  AcState? _pendingDesiredState;
  bool _isSyncing = false;

  @override
  Stream<AcState> get stateStream => _stateController.stream;

  @override
  Stream<bool> get isSyncingStream => _syncingController.stream;

  @override
  AcState get currentState => _currentState;

  @override
  bool get isSyncing => _isSyncing;

  /// Updates `/desiredState` in Firebase Realtime Database.
  ///
  /// Optimistically updates local state so the UI reacts immediately,
  /// and marks repository as [isSyncing] until `/confirmedState` emits matching values.
  @override
  Future<void> updateState(AcState newState) async {
    _pendingDesiredState = newState;
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
    _setSyncing(true);

    // Set fallback timeout so UI doesn't spin forever if device is offline
    _syncTimeoutTimer?.cancel();
    _syncTimeoutTimer = Timer(syncTimeout, () {
      if (_isSyncing) {
        _setSyncing(false);
        _pendingDesiredState = null;
      }
    });

    final payload = <String, dynamic>{
      'power': newState.isOn,
      'temp': newState.temperature,
      'mode': newState.mode.name,
      'fanSpeed': newState.fanSpeed.name,
      'swing': newState.swingEnabled,
      'flapPosition': newState.flapPosition,
      'timestamp': ServerValue.timestamp,
    };

    try {
      await _desiredRef.set(payload);
    } catch (_) {
      // Reset syncing state on write failure
      _syncTimeoutTimer?.cancel();
      _setSyncing(false);
      _pendingDesiredState = null;
      rethrow;
    }
  }

  Future<void> _seedConfirmedState() async {
    try {
      final initialPayload = <String, dynamic>{
        'power': _currentState.isOn,
        'temp': _currentState.temperature,
        'mode': _currentState.mode.name,
        'fanSpeed': _currentState.fanSpeed.name,
        'swing': _currentState.swingEnabled,
        'flapPosition': _currentState.flapPosition,
        'lastUpdatedBy': 'init',
        'timestamp': ServerValue.timestamp,
      };
      await _confirmedRef.set(initialPayload);
    } catch (_) {}
  }

  // ─── Real-Time Stream Handler ──────────────────────────────────────

  void _handleConfirmedStateEvent(DatabaseEvent event) {
    final value = event.snapshot.value;
    if (value == null) {
      _seedConfirmedState();
      return;
    }

    if (value is Map) {
      final confirmed = _stateFromMap(value);

      _currentState = confirmed;
      if (!_stateController.isClosed) {
        // Only push the confirmed state to the UI if we're not waiting for it
        // to match a pending desired state — otherwise the stale confirmed value
        // would briefly revert the optimistic UI update the user just made.
        if (!_isSyncing || _pendingDesiredState == null) {
          _stateController.add(confirmed);
        }
      }

      // Check if confirmedState matches our pending user request
      if (_isSyncing && _pendingDesiredState != null) {
        if (_matchesDesired(confirmed, _pendingDesiredState!)) {
          _syncTimeoutTimer?.cancel();
          _pendingDesiredState = null;
          _setSyncing(false);
          // Now that the device has confirmed, push the final state to the UI
          if (!_stateController.isClosed) {
            _stateController.add(confirmed);
          }
        }
      }
    }
  }

  bool _matchesDesired(AcState confirmed, AcState desired) {
    return confirmed.isOn == desired.isOn &&
        confirmed.temperature == desired.temperature &&
        confirmed.mode == desired.mode &&
        confirmed.fanSpeed == desired.fanSpeed &&
        confirmed.swingEnabled == desired.swingEnabled &&
        confirmed.flapPosition == desired.flapPosition;
  }

  void _setSyncing(bool syncing) {
    if (_isSyncing != syncing) {
      _isSyncing = syncing;
      if (!_syncingController.isClosed) {
        _syncingController.add(syncing);
      }
    }
  }

  // ─── Serialization Helpers ─────────────────────────────────────────

  AcState _stateFromMap(Map<dynamic, dynamic> map) {
    final power = _parseBool(
      map['power'] ?? map['isOn'],
      defaultValue: _currentState.isOn,
    );
    final temp = _parseInt(
      map['temp'] ?? map['temperature'],
      defaultValue: _currentState.temperature,
    );
    final mode = _parseMode(map['mode']);
    final fanSpeed = _parseFanSpeed(map['fanSpeed']);
    final swing = _parseBool(
      map['swing'] ?? map['swingEnabled'],
      defaultValue: _currentState.swingEnabled,
    );
    final flap = _parseInt(
      map['flapPosition'],
      defaultValue: _currentState.flapPosition,
    );

    return AcState(
      isOn: power,
      temperature: temp.clamp(18, 32),
      mode: mode,
      fanSpeed: fanSpeed,
      swingEnabled: swing,
      flapPosition: flap.clamp(1, 6),
    );
  }

  static bool _parseBool(dynamic val, {bool defaultValue = false}) {
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final lower = val.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'on';
    }
    return defaultValue;
  }

  static int _parseInt(dynamic val, {int defaultValue = 24}) {
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? defaultValue;
    return defaultValue;
  }

  static AcMode _parseMode(dynamic val) {
    if (val is String) {
      final lower = val.toLowerCase();
      for (final mode in AcMode.values) {
        if (mode.name.toLowerCase() == lower) return mode;
      }
    }
    return AcMode.cool;
  }

  static FanSpeed _parseFanSpeed(dynamic val) {
    if (val is String) {
      final lower = val.toLowerCase();
      for (final speed in FanSpeed.values) {
        if (speed.name.toLowerCase() == lower) return speed;
      }
    }
    return FanSpeed.auto;
  }

  @override
  void dispose() {
    _syncTimeoutTimer?.cancel();
    _confirmedSubscription?.cancel();
    _stateController.close();
    _syncingController.close();
  }
}
