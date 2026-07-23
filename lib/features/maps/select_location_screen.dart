import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class SelectLocationScreen extends ConsumerStatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  ConsumerState<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  final MapController _mapController = MapController();
  ll.LatLng _selectedLatLng = const ll.LatLng(23.8103, 90.4125);
  String _address = 'Dhaka, Bangladesh';

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _selectedLatLng = ll.LatLng(position.latitude, position.longitude);
          _address = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        });
        _mapController.move(_selectedLatLng, 14);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location (Free Map)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: _getUserLocation,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLatLng,
              initialZoom: 14,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLatLng = point;
                  _address = 'Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}';
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_lost_and_found',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLatLng,
                    width: 44,
                    height: 44,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selected Spot:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.outline)),
                    const SizedBox(height: 4),
                    Text(_address, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Confirm Location',
                      icon: Icons.check,
                      onPressed: () => context.pop(_address),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
