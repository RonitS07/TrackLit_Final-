import 'package:permission_handler/permission_handler.dart';

class PermissionsHelper {
  static Future<void> requestBleAndLocationPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ].request();
  }
}
