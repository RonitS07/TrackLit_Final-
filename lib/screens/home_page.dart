import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TrackLit/firebase/firebase_util.dart';
// IMPORTANT: Ensure this import is correct for your splash_screen.dart file location:
import 'package:TrackLit/splash_screen.dart'; // Import SplashScreen

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseUtil.getCurrentUser();

  Future<void> _handleLogout() async {
    try {
      await FirebaseUtil.signOut(); // Perform Firebase logout

      // Reset onboarding_completed flag in SharedPreferences upon logout.
      // This ensures that on the next app launch/re-evaluation via SplashScreen,
      // the onboarding flow can be triggered again.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', false); // Set to false to allow onboarding to show again

      if (mounted) {
        // Navigate to the SplashScreen, removing all previous routes from the stack.
        // SplashScreen will then re-evaluate the onboarding_completed flag
        // and guide the user to either Onboarding or Login/Signup.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()), // Go to SplashScreen
          (Route<dynamic> route) => false, // Clear all previous routes
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackLit Home'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          // The _resetOnboardingForDebug button/method has been removed.
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to TrackLit, ${user?.email ?? 'Guest'}!',
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/ble');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Go to BLE Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}