import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class SelectLocationScreen extends ConsumerStatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  ConsumerState<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  LatLng _selectedLatLng = const LatLng(23.8103, 90.4125);
  String _address = 'Dhaka, Bangladesh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _selectedLatLng, zoom: 14),
            onTap: (latLng) {
              setState(() {
                _selectedLatLng = latLng;
                _address = 'Lat: ${latLng.latitude.toStringAsFixed(4)}, Lng: ${latLng.longitude.toStringAsFixed(4)}';
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _selectedLatLng,
              ),
            },
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
