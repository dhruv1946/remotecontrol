import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'controllers/ac_controller.dart';
import 'data/ac_state_repository.dart';
import 'data/firebase_ac_state_repository.dart';
import 'firebase_options.dart';
import 'models/ac_state.dart';
import 'ui/remote_screen.dart';
import 'ui/theme.dart';

Future<void> ensureSignedIn() async {
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await ensureSignedIn();

  // ─── Firebase Realtime Database repository ───
  final AcStateRepository repository = FirebaseAcStateRepository(
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
