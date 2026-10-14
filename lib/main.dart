import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/ac_controller.dart';
import 'data/ac_state_repository.dart';
import 'data/mock_ac_state_repository.dart';
import 'models/ac_state.dart';
import 'ui/remote_screen.dart';
import 'ui/theme.dart';

void main() {
  // ─── Swap this for a FirebaseAcStateRepository later ───
  final AcStateRepository repository = MockAcStateRepository(
    initialState: const AcState(
      isOn: true,
      temperature: 24,
      mode: AcMode.cool,
      fanSpeed: FanSpeed.auto,
      swingEnabled: false,
      flapPosition: 3,
    ),
  );

  runApp(RemoteControlApp(repository: repository));
}

class RemoteControlApp extends StatelessWidget {
  const RemoteControlApp({super.key, required this.repository});
  final AcStateRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AcController(repository),
      child: MaterialApp(
        title: 'O General AC Remote',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const RemoteScreen(),
      ),
    );
  }
}
