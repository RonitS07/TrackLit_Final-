// lib/background/background_ble_task.dart

import 'package:workmanager/workmanager.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

const String bleScanTask = "scanAndLogBLE";

@pragma('vm:entry-point') // 👈 REQUIRED for WorkManager in AOT mode
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == bleScanTask) {
      try {
        await Firebase.initializeApp();

        final ble = FlutterReactiveBle();
        final List<DiscoveredDevice> discoveredDevices = [];

        final scanStream = ble.scanForDevices(
          withServices: [],
          scanMode: ScanMode.lowLatency,
        );

        final subscription = scanStream.listen((device) {
          if (!discoveredDevices.any((d) => d.id == device.id)) {
            discoveredDevices.add(device);
          }
        });

        // Wait for scan to complete
        await Future.delayed(const Duration(seconds: 5));
        await subscription.cancel();

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final firestore = FirebaseFirestore.instance;
        final auth = FirebaseAuth.instance;

        for (final device in discoveredDevices) {
          final macId = device.id;
          final name = device.name;
          final rssi = device.rssi;

          final doc = await firestore.collection('devices').doc(macId).get();
          if (!doc.exists) continue;

          final uid = auth.currentUser?.uid ?? 'anonymous';
          await firestore.collection('device_logs').add({
            'mac_id': macId,
            'device_name': name,
            'rssi': rssi,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'user_id': uid,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }

        return Future.value(true);
      } catch (e) {
        print("BLE Background Error: $e");
        return Future.value(false);
      }
    }

    return Future.value(false);
  });
}
