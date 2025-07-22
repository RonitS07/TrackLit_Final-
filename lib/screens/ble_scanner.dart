// lib/pages/ble_scanner.dart

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndStartScan();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _requestPermissionsAndStartScan() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    flutterReactiveBle
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiscoveredDevice> get _filteredDevices {
    return _devices.where((d) {
      final name = d.name.toLowerCase();
      final id = d.id.toLowerCase();
      return name.contains(_searchText) || id.contains(_searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE Device Scanner"),
        centerTitle: true,
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
                      return ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(d.name.isNotEmpty ? d.name : "Unnamed"),
                        subtitle: Text("MAC: ${d.id} | RSSI: ${d.rssi}"),
                      );
                    },
                  ),
          ),
        ],
),
);
}
}
