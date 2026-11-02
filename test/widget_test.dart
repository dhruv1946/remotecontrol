import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_control/main.dart';
import 'package:remote_control/controllers/ac_controller.dart';
import 'package:remote_control/models/ac_state.dart';
import 'mocks/mock_ac_state_repository.dart';

void main() {
  group('RemoteControlApp Widget & UI Tests', () {
    testWidgets('App renders with initial state', (WidgetTester tester) async {
      final repository = MockAcStateRepository(
        initialState: const AcState(isOn: true, temperature: 24),
      );

      await tester.pumpWidget(RemoteControlApp(repository: repository));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const ValueKey(24)), findsOneWidget);
      expect(find.text('O General AC'), findsOneWidget);

      repository.dispose();
    });

    testWidgets('User increments temperature optimistically', (WidgetTester tester) async {
      final repository = MockAcStateRepository(
        initialState: const AcState(isOn: true, temperature: 24),
      );

      await tester.pumpWidget(RemoteControlApp(repository: repository));
      await tester.pump(const Duration(milliseconds: 300));

      final plusFinder = find.widgetWithText(GestureDetector, '+');
      expect(plusFinder, findsOneWidget);

      await tester.tap(plusFinder);
      await tester.pump(const Duration(milliseconds: 300));

      expect(repository.currentState.temperature, 25);
      expect(find.byKey(const ValueKey(25)), findsOneWidget);

      repository.dispose();
    });

    testWidgets('Rollback and SnackBar error message on failed action', (WidgetTester tester) async {
      final repository = MockAcStateRepository(
        initialState: const AcState(isOn: true, temperature: 24),
        shouldFailWrites: true,
      );

      await tester.pumpWidget(RemoteControlApp(repository: repository));
      await tester.pump(const Duration(milliseconds: 300));

      final plusFinder = find.widgetWithText(GestureDetector, '+');
      await tester.tap(plusFinder);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // State should have rolled back to 24
      expect(repository.currentState.temperature, 24);
      expect(find.byKey(const ValueKey(24)), findsOneWidget);

      // SnackBar should be visible with error message
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Failed to update AC state'), findsOneWidget);

      repository.dispose();
    });
  });

  group('AcController Unit Tests', () {
    test('Increment and decrement temp clamps appropriately', () async {
      final repo = MockAcStateRepository(
        initialState: const AcState(isOn: true, temperature: 32),
      );
      final controller = AcController(repo);

      await controller.incrementTemp();
      expect(controller.temperature, 32); // Clamped at 32

      await controller.decrementTemp();
      expect(controller.temperature, 31);

      controller.dispose();
      repo.dispose();
    });

    test('Toggling swing sets swingEnabled properly', () async {
      final repo = MockAcStateRepository(
        initialState: const AcState(isOn: true, swingEnabled: false),
      );
      final controller = AcController(repo);

      await controller.toggleSwing();
      expect(controller.swingEnabled, true);

      await controller.toggleSwing();
      expect(controller.swingEnabled, false);

      controller.dispose();
      repo.dispose();
    });

    test('Cycle flap position steps 1 to 6 and loops', () async {
      final repo = MockAcStateRepository(
        initialState: const AcState(isOn: true, flapPosition: 5, swingEnabled: true),
      );
      final controller = AcController(repo);

      await controller.cycleFlapPosition();
      expect(controller.flapPosition, 6);
      expect(controller.swingEnabled, false); // Setting flap disables swing

      await controller.cycleFlapPosition();
      expect(controller.flapPosition, 1);

      controller.dispose();
      repo.dispose();
    });
  });

  group('AcState Model Tests', () {
    test('Angles and descriptions match specifications', () {
      const state1 = AcState(flapPosition: 1);
      expect(state1.flapAngleDegrees, 15);
      expect(state1.flapDescription, '15° High');

      const state6 = AcState(flapPosition: 6);
      expect(state6.flapAngleDegrees, 90);
      expect(state6.flapDescription, '90° Floor');
    });

    test('Equality and copyWith operate predictably', () {
      const s1 = AcState(temperature: 22, mode: AcMode.cool);
      final s2 = s1.copyWith(temperature: 25);

      expect(s1 == s2, false);
      expect(s2.temperature, 25);
      expect(s2.mode, AcMode.cool);
    });
  });
}
