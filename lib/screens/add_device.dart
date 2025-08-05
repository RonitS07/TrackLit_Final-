import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final flutterBle = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSub;
  final _knownDevices = <String, Map<String, dynamic>>{}; // macId -> full doc
  final _foundDevices = <DiscoveredDevice>[];
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _loadKnownDevices();
  }

  Future<void> _loadKnownDevices() async {
    final snap = await FirebaseFirestore.instance.collection('devices').get();
    for (var doc in snap.docs) {
      final data = doc.data();
      final mac = data['mac_id'];
      if (mac != null) {
        _knownDevices[mac] = {
          ...data,
          'docId': doc.id,
        };
      }
    }
  }

  void _startScan() {
    _foundDevices.clear();
    _scanSub = flutterBle.scanForDevices(withServices: []).listen(
      (device) {
        if (_knownDevices.containsKey(device.id)) {
          if (!_foundDevices.any((d) => d.id == device.id)) {
            setState(() => _foundDevices.add(device));
          }
        }
      },
      onError: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
      },
    );
    setState(() => _scanning = true);
  }

  void _stopScan() {
    _scanSub?.cancel();
    _scanSub = null;
    setState(() => _scanning = false);
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  void _linkDevice(DiscoveredDevice device) {
    final controller = TextEditingController();
    final info = _knownDevices[device.id]!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Link ${info['name'] ?? device.id}"),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Enter Password"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final expectedPassword = info['password'];
              if (expectedPassword == controller.text.trim()) {
                final uid = FirebaseAuth.instance.currentUser!.uid;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('linked_devices')
                    .doc(info['docId'])
                    .set({});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Device linked successfully')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect password')));
              }
            },
            child: const Text("Link"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Device"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton.icon(
              onPressed: _scanning ? _stopScan : _startScan,
              icon: Icon(_scanning ? Icons.stop : Icons.bluetooth),
              label: Text(_scanning ? "Stop Scan" : "Scan BLE Devices"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _foundDevices.isEmpty
                ? Center(
                    child: Text(
                      _scanning ? 'Scanning...' : 'No devices found',
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _foundDevices.length,
                    itemBuilder: (context, i) {
                      final d = _foundDevices[i];
                      final info = _knownDevices[d.id];
                      final name = info?['name'] ?? 'Unnamed Device';
                      final type = info?['type'] ?? 'BLE Device';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(name),
                          subtitle: Text('$type • ${d.id}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _linkDevice(d),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
