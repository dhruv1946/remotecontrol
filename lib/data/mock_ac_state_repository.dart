import 'dart:async';
import '../models/ac_state.dart';
import 'ac_state_repository.dart';

/// In-memory mock implementation of [AcStateRepository].
///
/// Stores state in memory and provides a reactive broadcast stream.
/// State ONLY changes when explicitly updated via user actions.
class MockAcStateRepository extends AcStateRepository {
  MockAcStateRepository({
    AcState initialState = const AcState(),
  }) : _state = initialState {
    _controller = StreamController<AcState>.broadcast();

    // Emit the initial state so listeners get a value immediately.
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
    // Simulate a tiny network delay.
    await Future<void>.delayed(const Duration(milliseconds: 80));
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
