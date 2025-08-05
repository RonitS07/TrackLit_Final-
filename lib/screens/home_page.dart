import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Screens
import 'package:TrackLit/firebase/firebase_util.dart';
import 'package:TrackLit/screens/add_device.dart';
import 'package:TrackLit/screens/lost_and_found.dart';
import 'package:TrackLit/screens/profile.dart';
import 'package:TrackLit/screens/device_details.dart';

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

  int _estimateBattery(int rssi) =>
      ((rssi + 90) / 60 * 100).clamp(0, 100).round();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackLit Home'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('linked_devices')
            .snapshots(),
        builder: (context, snapLink) {
          if (!snapLink.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final linkedDocs = snapLink.data!.docs;
          if (linkedDocs.isEmpty) {
            return const Center(child: Text('No linked devices yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: linkedDocs.length,
            itemBuilder: (context, index) {
              final deviceId = linkedDocs[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('devices')
                    .doc(deviceId)
                    .get(),
                builder: (ctx, snapDev) {
                  if (!snapDev.hasData || !snapDev.data!.exists) {
                    return const SizedBox();
                  }

                  final device = snapDev.data!.data() as Map<String, dynamic>;
                  final name = device['name'] ?? 'Unnamed';
                  final mac = device['mac_id'] ?? '';

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('device_logs')
                        .where('mac_id', isEqualTo: mac)
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .get(),
                    builder: (ctx2, snapLog) {
                      Map<String, dynamic>? log;
                      if (snapLog.hasData && snapLog.data!.docs.isNotEmpty) {
                        log = snapLog.data!.docs.first.data()
                            as Map<String, dynamic>;
                      }

                      final timestamp = log?['timestamp']?.toDate();
                      final battery =
                          log != null ? _estimateBattery(log['rssi']) : null;
                      final lat = log?['latitude'];
                      final lng = log?['longitude'];
                      final isLive = timestamp != null &&
                          DateTime.now().difference(timestamp).inMinutes < 5;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(name,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MAC: $mac'),
                            if (timestamp != null)
                              Text(
                                  'Last seen: ${DateFormat.yMMMd().add_jm().format(timestamp)}'),
                            if (battery != null) Text('Battery: $battery%'),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: lat != null && lng != null && timestamp != null
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DeviceDetailPage(
                                      deviceName: name,
                                      lat: lat,
                                      lng: lng,
                                      battery: battery,
                                      seenAt: timestamp,
                                      isLive: isLive,
                                    ),
                                  ),
                                )
                            : () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No location data for this device'))),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
