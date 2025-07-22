import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Corrected imports using 'TrackLit' package name for screen files

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 1)); // Optional splash delay

    final prefs = await SharedPreferences.getInstance();
    // Ensure this key ('onboarding_completed') is consistently used everywhere.
    final onboardingDone = prefs.getBool('onboarding_completed') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, navigate to Home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/'); // Use named route for home
      }
    } else if (onboardingDone) {
      // User is not logged in, but onboarding was completed (first time viewing it)
      // Navigate to login page
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login'); // Use named route for login
      }
    } else {
      // First time user, onboarding not yet completed
      // Navigate to onboarding screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding'); // Use named route for onboarding
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.black, // Consistent color
        ),
      ),
    );
  }
}