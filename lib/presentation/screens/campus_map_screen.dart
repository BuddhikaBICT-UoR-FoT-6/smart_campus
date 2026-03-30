import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../app/theme.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});

  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();

  // Mock university coordinates (e.g., University of Ruhuna, Faculty of Technology center)
  final LatLng _campusCenter = const LatLng(6.064, 80.536);

  final List<Marker> _campusMarkers = [
    Marker(
      point: const LatLng(6.0645, 80.5362),
      width: 80,
      height: 80,
      child: const Icon(Icons.business, color: Colors.blue, size: 30),
    ),
    Marker(
      point: const LatLng(6.0635, 80.5355),
      width: 80,
      height: 80,
      child: const Icon(Icons.school, color: Colors.green, size: 30),
    ),
    Marker(
      point: const LatLng(6.0650, 80.5370),
      width: 80,
      height: 80,
      child: const Icon(Icons.local_cafe, color: Colors.orange, size: 30),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      
      // Optionally move camera to user location
      _mapController.move(_currentPosition!, 16.0);
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.move(_currentPosition!, 16.0);
              } else {
                _determinePosition();
              }
            },
            tooltip: 'My Location',
          ),
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () {
              _mapController.move(_campusCenter, 16.0);
            },
            tooltip: 'Campus Center',
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _campusCenter,
          initialZoom: 16.0,
          maxZoom: 19.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.smart_campus',
          ),
          MarkerLayer(
            markers: [
              ..._campusMarkers,
              if (_currentPosition != null)
                Marker(
                  point: _currentPosition!,
                  width: 80,
                  height: 80,
                  child: const Column(
                    children: [
                      Icon(Icons.person_pin_circle, color: AppTheme.primary, size: 40),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
