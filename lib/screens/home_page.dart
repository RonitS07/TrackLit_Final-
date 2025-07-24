import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:TrackLit/firebase/firebase_util.dart';

// Screens
import 'package:TrackLit/screens/add_device.dart';
import 'package:TrackLit/screens/lost_and_found.dart';
import 'package:TrackLit/screens/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseUtil.getCurrentUser();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreenContent(),
    const AddDevicePage(),
    const LostAndFoundPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _pages[_currentIndex],
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.black26, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.black45,
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.home),
                      label: _currentIndex == 0 ? 'Home' : '',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.bluetooth),
                      label: _currentIndex == 1 ? 'Add Device' : '',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.search),
                      label: _currentIndex == 2 ? 'Lost & Found' : '',
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.person),
                      label: _currentIndex == 3 ? 'Profile' : '',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseUtil.getCurrentUser();
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackLit Home'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Welcome to TrackLit, ${user?.email ?? 'Guest'}!',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
