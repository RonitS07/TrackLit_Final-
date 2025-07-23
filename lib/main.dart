import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'background/background_ble_task.dart';
import 'package:TrackLit/routes/app_routes.dart';
import 'package:TrackLit/firebase_options.dart';
import 'package:TrackLit/splash_screen.dart'; // Ensure SplashScreen is directly imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final flutterReactiveBle = FlutterReactiveBle();

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );

  await Workmanager().registerPeriodicTask(
    "bleScanTask",
    "scanAndLogBLE",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
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
      home: const SplashScreen(), // ✅ Always start from SplashScreen
      routes: AppRoutes.routes, // ✅ No conflict with '/'
    );
  }
}
