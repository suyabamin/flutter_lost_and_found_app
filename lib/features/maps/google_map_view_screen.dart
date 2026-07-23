import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class GoogleMapViewScreen extends ConsumerStatefulWidget {
  const GoogleMapViewScreen({super.key});

  @override
  ConsumerState<GoogleMapViewScreen> createState() => _GoogleMapViewScreenState();
}

class _GoogleMapViewScreenState extends ConsumerState<GoogleMapViewScreen> {
  static const LatLng _dhakaCenter = LatLng(23.8103, 90.4125);
  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('lost_1'),
      position: LatLng(23.7937, 90.4066),
      infoWindow: InfoWindow(title: 'Lost iPhone 14 Pro', snippet: 'Banani Road 11'),
    ),
    const Marker(
      markerId: MarkerId('found_1'),
      position: LatLng(23.7461, 90.3742),
      infoWindow: InfoWindow(title: 'Found Brown Leather Wallet', snippet: 'Dhanmondi 27'),
    ),
    const Marker(
      markerId: MarkerId('lost_2'),
      position: LatLng(23.8759, 90.3795),
      infoWindow: InfoWindow(title: 'Lost House Keys Cluster', snippet: 'Uttara Sector 4'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Map View'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _dhakaCenter,
              zoom: 12.5,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.pin_drop_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('3 Items Found Nearby', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('Tap markers to view details & claim', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/search-results'),
                    child: const Text('List View'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
