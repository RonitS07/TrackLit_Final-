import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  IconData _getBatteryIcon(int battery) {
    if (battery >= 80) return Icons.battery_full;
    if (battery >= 50) return Icons.battery_5_bar;
    if (battery >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  Future<void> _openInGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

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
        onTap: _openInGoogleMaps,
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
                if (isLive)
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.only(right: 6),
                      ),
                      Text(
                        seenLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    seenLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
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
                      Icon(_getBatteryIcon(battery!), size: 20),
                      const SizedBox(width: 8),
                      Text('Battery: $battery%'),
                    ],
                  )
                else
                  const Text('Battery data unavailable'),
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
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
