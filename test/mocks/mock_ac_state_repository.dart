import 'dart:async';
import 'package:remote_control/data/ac_state_repository.dart';
import 'package:remote_control/models/ac_state.dart';

/// In-memory mock implementation of [AcStateRepository] for testing.
///
/// Stores state in memory and provides a reactive broadcast stream with
/// optional syncing simulation and failure simulation.
class MockAcStateRepository extends AcStateRepository {
  MockAcStateRepository({
    AcState initialState = const AcState(),
    this.shouldFailWrites = false,
    this.autoConfirm = false,
  })  : _state = initialState,
        _lastConfirmedState = initialState {
    _stateController = StreamController<AcState>.broadcast();
    _syncingController = StreamController<bool>.broadcast();
    _stateController.add(_state);
    _syncingController.add(false);
  }

  AcState _state;
  AcState _lastConfirmedState;
  bool shouldFailWrites;
  bool autoConfirm;
  bool _isSyncing = false;

  late final StreamController<AcState> _stateController;
  late final StreamController<bool> _syncingController;

  @override
  Stream<AcState> get stateStream => _stateController.stream;

  @override
  Stream<bool> get isSyncingStream => _syncingController.stream;

  @override
  AcState get currentState => _state;

  @override
  bool get isSyncing => _isSyncing;

  @override
  Future<void> updateState(AcState newState) async {
    final rollback = _state;
    _state = newState;
    _isSyncing = true;
    _stateController.add(newState);
    _syncingController.add(true);

    if (shouldFailWrites) {
      _isSyncing = false;
      _state = rollback;
      _stateController.add(rollback);
      _syncingController.add(false);
      throw Exception('Network simulated failure');
    }

    if (autoConfirm) {
      _isSyncing = false;
      _lastConfirmedState = newState;
      _syncingController.add(false);
    }
  }

  void simulateRemoteConfirmation(AcState confirmed) {
    _lastConfirmedState = confirmed;
    _state = confirmed;
    _isSyncing = false;
    _stateController.add(confirmed);
    _syncingController.add(false);
  }

  void simulateTimeoutRollback() {
    _state = _lastConfirmedState;
    _isSyncing = false;
    _stateController.add(_lastConfirmedState);
    _syncingController.add(false);
  }

  @override
  void dispose() {
    _stateController.close();
    _syncingController.close();
  }
}
