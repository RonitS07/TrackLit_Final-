import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:TrackLit/screens/home_page.dart';

final flutterReactiveBle = FlutterReactiveBle();

class BleScannerPage extends StatefulWidget {
  const BleScannerPage({super.key});

  @override
  State<BleScannerPage> createState() => _BleScannerPageState();
}

class _BleScannerPageState extends State<BleScannerPage> {
  final List<DiscoveredDevice> _devices = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  final Map<String, Map<String, dynamic>> _knownDevices = {}; // mac -> device data
  StreamSubscription<DiscoveredDevice>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _loadKnownDevices();
    _requestPermissionsAndStartScan();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadKnownDevices() async {
    final snap = await FirebaseFirestore.instance.collection('devices').get();
    for (var doc in snap.docs) {
      final data = doc.data();
      final mac = data['mac_id'];
      if (mac != null) {
        _knownDevices[mac.toLowerCase()] = {
          ...data,
          'docId': doc.id,
        };
      }
    }
  }

  Future<void> _requestPermissionsAndStartScan() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses.values.any((status) => !status.isGranted)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please grant all permissions to scan devices.')),
        );
      }
      return;
    }

    _scanSubscription = flutterReactiveBle
        .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
        .listen((device) {
      setState(() {
        final index = _devices.indexWhere((d) => d.id == device.id);
        if (index >= 0) {
          _devices[index] = device;
        } else {
          _devices.add(device);
        }
      });
    });
  }

  List<DiscoveredDevice> get _filteredDevices {
    return _devices.where((d) {
      final name = d.name.toLowerCase();
      final id = d.id.toLowerCase();
      return name.contains(_searchText) || id.contains(_searchText);
    }).toList();
  }

  void _promptLinking(DiscoveredDevice device) {
    final info = _knownDevices[device.id.toLowerCase()];
    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This device is not registered.')),
      );
      return;
    }

    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Link ${info['name'] ?? 'Unnamed Device'}'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Enter Password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final expectedPassword = info['password'];
              final enteredPassword = controller.text.trim();

              if (enteredPassword == expectedPassword) {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('linked_devices')
                    .doc(info['docId'])
                    .set({});

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Device linked successfully")),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect password")),
                );
              }
            },
            child: const Text("Link"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE Device Scanner"),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name or MAC ID",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredDevices.isEmpty
                ? const Center(child: Text("No devices found."))
                : ListView.builder(
                    itemCount: _filteredDevices.length,
                    itemBuilder: (context, index) {
                      final d = _filteredDevices[index];
                      final info = _knownDevices[d.id.toLowerCase()];
                      final name = info?['name'] ?? (d.name.isNotEmpty ? d.name : 'Unnamed');
                      return ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(name),
                        subtitle: Text("MAC: ${d.id} | RSSI: ${d.rssi}"),
                        onTap: () => _promptLinking(d),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
