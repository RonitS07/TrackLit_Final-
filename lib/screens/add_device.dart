import 'package:flutter/material.dart';
import 'package:TrackLit/routes/app_routes.dart';

class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Device"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.bleScanner);
          },
          icon: const Icon(Icons.bluetooth),
          label: const Text("Scan BLE Devices"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }
}
