import 'package:flutter/material.dart';
// IMPORTANT: Ensure this import path matches your firebase_util.dart file location:
import 'package:TrackLit/firebase/firebase_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuthException
import 'package:logger/logger.dart'; // Import the logger package

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final Logger _logger = Logger(); // Initialize logger for this page

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = await FirebaseUtil.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Set onboarding completed flag after successful login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true); // Consistent key

      // Navigate to home page
      if (mounted) { // Check if the widget is still in the tree before navigating
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = e.message ?? 'An unknown error occurred during login.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      _logger.e("FirebaseAuthException during login: ${e.code}, ${e.message}"); // Log error
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      _logger.e("General error during login: $e"); // Log error
    } finally {
      if (mounted) { // Ensure setState is only called if widget is still mounted
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential = await FirebaseUtil.signInWithGoogle();

      // Set onboarding completed flag after successful Google Sign-In
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true); // Consistent key

      // Navigate to home page
      if (mounted) { // Check if the widget is still in the tree before navigating
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Error: ${e.message}')),
        );
      }
      _logger.e("Google Sign-In FirebaseAuthException: ${e.code}, ${e.message}"); // Log error
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      _logger.e("General error during Google Sign-In: $e"); // Log error
    } finally {
      if (mounted) { // Ensure setState is only called if widget is still mounted
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Already white, matching desired aesthetic
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.black54), // Matching aesthetic
                  filled: true,
                  fillColor: Colors.grey[200], // Matching aesthetic
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black54), // Matching aesthetic
                  filled: true,
                  fillColor: Colors.grey[200], // Matching aesthetic
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Matching aesthetic
                        foregroundColor: Colors.white, // Matching aesthetic
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _handleLogin,
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black, // Matching aesthetic
                  side: const BorderSide(color: Colors.black26), // Matching aesthetic
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _handleGoogleSignIn,
                // IMPORTANT: Updated path to match pubspec.yaml
                icon: Image.asset('assets/logos/google_logo.jpg', height: 24), // Updated path
                label: const Text(
                  "Login with Google",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Using pushReplacementNamed to prevent going back to Login
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Colors.black87), // Matching aesthetic
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}