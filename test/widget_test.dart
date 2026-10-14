import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remote_control/main.dart';
import 'package:remote_control/data/mock_ac_state_repository.dart';
import 'package:remote_control/models/ac_state.dart';

void main() {
  testWidgets('App renders with power button and temperature', (WidgetTester tester) async {
    final repository = MockAcStateRepository(
      initialState: const AcState(isOn: true, temperature: 24),
    );

    await tester.pumpWidget(RemoteControlApp(repository: repository));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify the app renders with the temperature and O General AC header.
    expect(find.byKey(const ValueKey(24)), findsOneWidget);
    expect(find.text('O General AC'), findsOneWidget);

    repository.dispose();
  });
}
