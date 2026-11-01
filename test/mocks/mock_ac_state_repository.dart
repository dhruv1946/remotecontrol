import 'dart:async';
import 'package:remote_control/data/ac_state_repository.dart';
import 'package:remote_control/models/ac_state.dart';

/// In-memory mock implementation of [AcStateRepository] for testing.
///
/// Stores state in memory and provides a reactive broadcast stream.
class MockAcStateRepository extends AcStateRepository {
  MockAcStateRepository({
    AcState initialState = const AcState(),
  }) : _state = initialState {
    _controller = StreamController<AcState>.broadcast();
    _controller.add(_state);
  }

  AcState _state;
  late final StreamController<AcState> _controller;

  @override
  Stream<AcState> get stateStream => _controller.stream;

  @override
  AcState get currentState => _state;

  @override
  Future<void> updateState(AcState newState) async {
    _state = newState;
    if (!_controller.isClosed) {
      _controller.add(_state);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}
