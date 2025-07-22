import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;
  Timer? _timer;

  final List<Map<String, String>> _slides = [
    {
      "title": "Welcome",
      "desc": "Your smart companion for device tracking.",
      "anim": "assets/lottie/welcome.json"
    },
    {
      "title": "Effortless Linking",
      "desc": "Easily pair and manage your smart devices.",
      "anim": "assets/lottie/track_device.json"
    },
    {
      "title": "Lost & Found",
      "desc": "Never lose your device again with our powerful system.",
      "anim": "assets/lottie/lost_found.json"
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_controller.hasClients) {
        int nextPage = _controller.page!.round() + 1;
        if (nextPage < _slides.length) {
          _controller.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _timer?.cancel();
        }
      }
    });
  }

  // New function to mark onboarding as completed
  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true); // Standardize the key
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // Exit app on back press
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() {
                  onLastPage = index == _slides.length - 1;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(30),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        _slides[index]["anim"]!,
                        height: 250,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _slides[index]["title"]!,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _slides[index]["desc"]!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Page Indicator
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: _slides.length,
                  effect: const WormEffect(
                    dotColor: Colors.black26,
                    activeDotColor: Colors.black,
                  ),
                ),
              ),
            ),

            // Login & Signup Buttons
              Positioned(
                bottom: 30,
                left: 40,
                right: 40,
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async { // Make onPressed async
                        await _completeOnboarding(); // Mark onboarding as complete
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text("Login"),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                      ),
                      onPressed: () async { // Make onPressed async
                        await _completeOnboarding(); // Mark onboarding as complete
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: const Text("Create Account"),
                    ),
                  ],
                ),
              ),

            // Skip Button (top-right)
            Positioned(
              top: 40,
              right: 20,
              child: TextButton(
                onPressed: () async { // Make onPressed async
                  await _completeOnboarding(); // Mark onboarding as complete
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}