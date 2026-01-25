import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection.dart';
import 'data/services/api_bridge_service.dart';
import 'presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (with error handling)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase might not be configured yet, continue without it
    print('Firebase initialization failed: $e');
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Configure dependencies (SharedPreferences will be initialized via module)
  await configureDependencies();
  
  // Initialize API bridge service for native-to-Flutter API calls
  try {
    final apiBridgeService = getIt<ApiBridgeService>();
    await apiBridgeService.initialize();
  } catch (e) {
    print('Failed to initialize ApiBridgeService: $e');
  }

  runApp(
    const ProviderScope(
      child: SekretessApp(),
    ),
  );
}

class SekretessApp extends StatelessWidget {
  const SekretessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sekretess',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
