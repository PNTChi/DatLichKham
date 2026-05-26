import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/app_colors.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.762622, 106.660172), // Tọa độ trung tâm HCM
    zoom: 14.0,
  );

  final Set<Marker> _markers = {
    const Marker(markerId: MarkerId('h1'), position: LatLng(10.757398, 106.657788), infoWindow: InfoWindow(title: 'Bệnh viện Chợ Rẫy')),
    const Marker(markerId: MarkerId('h2'), position: LatLng(10.7554, 106.6654), infoWindow: InfoWindow(title: 'Bệnh viện ĐH Y Dược')),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ Bệnh viện', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: _markers,
        myLocationEnabled: true,
      ),
    );
  }
}