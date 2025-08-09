// lib/background/background_ble_task.dart

import 'package:workmanager/workmanager.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:TrackLit/firebase_options.dart'; // adjust path if needed

const String bleScanTask = "scanAndLogBLE";

String normalizeMac(String mac) {
  // Uppercase and ensure colon separators (if your device ids include colons).
  // Adjust normalization to match how you store mac_id in Firestore.
  return mac.toUpperCase().replaceAll('-', ':');
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != bleScanTask) return Future.value(false);

    try {
      // Initialize Firebase with options (safer for background isolate)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final ble = FlutterReactiveBle();
      final List<DiscoveredDevice> discoveredDevices = [];

      // Start scanning
      final scanStream = ble.scanForDevices(
        withServices: [],
        scanMode: ScanMode.lowLatency,
      );

      final subscription = scanStream.listen((device) {
        if (!discoveredDevices.any((d) => d.id == device.id)) {
          discoveredDevices.add(device);
        }
      });

      // Scan longer for reliability in background
      await Future.delayed(const Duration(seconds: 10));
      await subscription.cancel();

      // Try to get location safely (may fail in background)
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        // location might fail in background - continue without it
        print("Background location error: $e");
        position = null;
      }

      final firestore = FirebaseFirestore.instance;

      // Get uid from inputData if passed when scheduling task; else '', treat as anonymous
      final uidFromInput = (inputData != null && inputData['uid'] != null)
          ? (inputData['uid'] as String)
          : '';

      for (final device in discoveredDevices) {
        try {
          final macId = normalizeMac(device.id);
          final name = device.name;
          final rssi = device.rssi;

          // Only process if the device exists in Firestore 'devices' collection
          final deviceDocRef = firestore.collection('devices').doc(macId);
          final docSnap = await deviceDocRef.get();
          if (!docSnap.exists) {
            // Optionally you could create a device doc here, but current logic ignores unknown devices
            continue;
          }

          // Add a log entry to device_logs
          await firestore.collection('device_logs').add({
            'mac_id': macId,
            'device_name': name,
            'rssi': rssi,
            'latitude': position?.latitude,
            'longitude': position?.longitude,
            'user_id': uidFromInput.isNotEmpty ? uidFromInput : null,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Also update the main device document with last seen data (merge to keep other fields)
          final Map<String, dynamic> updateData = {
            'last_seen': FieldValue.serverTimestamp(),
            'last_rssi': rssi,
          };
          if (position != null) {
            updateData['last_latitude'] = position.latitude;
            updateData['last_longitude'] = position.longitude;
          }
          if (uidFromInput.isNotEmpty) {
            updateData['last_user'] = uidFromInput;
          }

          await deviceDocRef.set(updateData, SetOptions(merge: true));
        } catch (e) {
          print("Error logging/updating device ${device.id}: $e");
          // continue with next device
        }
      }

      return Future.value(true);
    } catch (e) {
      print("BLE Background Task failed: $e");
      return Future.value(false);
    }
  });
}
