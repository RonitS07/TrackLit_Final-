import 'package:flutter/material.dart';
// Core screens
import 'package:TrackLit/screens/login.dart';
import 'package:TrackLit/screens/onboarding/onboarding_screen.dart';
import 'package:TrackLit/screens/signup.dart';
import 'package:TrackLit/splash_screen.dart';
// BLE Scanner
import 'package:TrackLit/screens/ble_scanner.dart';
// Profile Page
import 'package:TrackLit/screens/profile.dart';
// Lost and Found Page
import 'package:TrackLit/screens/lost_and_found.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String splash = '/splash';
  static const String bleScanner = '/ble';
  static const String profile = '/profile';
  static const String lostFound = '/lostAndFound';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    signup: (context) => const SignupPage(),
    onboarding: (context) => const OnboardingScreen(),
    splash: (context) => const SplashScreen(),
    bleScanner: (context) => const BleScannerPage(),
    profile: (context) => const ProfilePage(),
    lostFound: (context) => const LostAndFoundPage(), // ✅ Fixed class name
  };
}
