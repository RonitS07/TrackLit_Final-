import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// IMPORTANT: Ensure this import path is correct for your app_routes.dart file
import 'package:TrackLit/routes/app_routes.dart';
import 'package:TrackLit/firebase_options.dart'; // Ensure this file exists and is correctly configured

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // The SplashScreen will now handle the initial routing logic based on onboarding status and user login.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackLit', // Your app's title
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      // Set the initial route to SplashScreen.
      // SplashScreen will then determine whether to go to Onboarding, Login, or Home.
      initialRoute: AppRoutes.splash,
      // This includes all your defined routes, including '/splash'
      routes: {
        ...AppRoutes.routes,
      },
    );
  }
}