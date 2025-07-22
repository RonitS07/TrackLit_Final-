import 'package:flutter/material.dart';
// IMPORTANT: Ensure these import paths are correct for your screen files:
import 'package:TrackLit/screens/home_page.dart';
import 'package:TrackLit/screens/login.dart';
import 'package:TrackLit/screens/onboarding/onboarding_screen.dart';
import 'package:TrackLit/screens/signup.dart';
import 'package:TrackLit/splash_screen.dart';
// IMPORTANT: Make sure this file exists at the specified path for the '/ble' route:
import 'package:TrackLit/screens/ble_scanner.dart'; // Example: Ensure this path is correct

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String splash = '/splash'; // Route name for SplashScreen
  static const String bleScanner = '/ble'; // Route name for your BLE scanner page

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),
    onboarding: (context) => const OnboardingScreen(),
    splash: (context) => const SplashScreen(), // Mapping SplashScreen to its route
    bleScanner: (context) => const BleScannerPage(), // Mapping your BLE scanner page
  };
}