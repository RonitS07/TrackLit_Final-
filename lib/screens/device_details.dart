import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class DeviceDetailPage extends StatelessWidget {
  final String deviceName;
  final double lat;
  final double lng;
  final int? battery;
  final DateTime seenAt;
  final bool isLive;

  const DeviceDetailPage({
    super.key,
    required this.deviceName,
    required this.lat,
    required this.lng,
    required this.battery,
    required this.seenAt,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final seenLabel = isLive ? 'Live Now' : 'Last Seen';
    final formattedTime = DateFormat.yMMMd().add_jm().format(seenAt);

    final marker = Marker(
      markerId: MarkerId(deviceName),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: deviceName,
        snippet: '$seenLabel • $formattedTime',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seenLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLive ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                if (battery != null)
                  Row(
                    children: [
                      const Icon(Icons.battery_full, size: 20),
                      const SizedBox(width: 8),
                      Text('Battery: $battery%'),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 15,
              ),
              markers: {marker},
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
