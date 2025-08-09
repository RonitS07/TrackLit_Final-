import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'background/background_ble_task.dart';
import 'package:TrackLit/routes/app_routes.dart';
import 'package:TrackLit/firebase_options.dart';
import 'package:TrackLit/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final flutterReactiveBle = FlutterReactiveBle();

  // Get the current logged-in user's UID (if any)
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  // Register background task with UID so it logs correctly for the user
  await Workmanager().registerPeriodicTask(
    "bleScanTask",
    "scanAndLogBLE",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    inputData: {
      'uid': uid, // ✅ Pass UID to background task
    },
    existingWorkPolicy: ExistingWorkPolicy.keep, // Avoid duplicate registrations
  );

  runApp(MyApp(ble: flutterReactiveBle));
}

class MyApp extends StatelessWidget {
  final FlutterReactiveBle ble;
  const MyApp({super.key, required this.ble});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackLit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SplashScreen(), // Always start from SplashScreen
      routes: AppRoutes.routes,
    );
  }
}



