import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/models/post_model.dart';
import '../../core/providers/providers.dart';

class GoogleMapViewScreen extends ConsumerStatefulWidget {
  const GoogleMapViewScreen({super.key});

  @override
  ConsumerState<GoogleMapViewScreen> createState() => _GoogleMapViewScreenState();
}

class _GoogleMapViewScreenState extends ConsumerState<GoogleMapViewScreen> {
  final MapController _mapController = MapController();
  ll.LatLng _currentLocation = const ll.LatLng(23.8103, 90.4125);
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoadingLocation = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = ll.LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });

        _mapController.move(_currentLocation, 14);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Free Map View'),
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
      body: postsAsync.when(
        data: (posts) {
          final List<Marker> markers = [];

          // Current User Location Marker
          markers.add(
            Marker(
              point: _currentLocation,
              width: 44,
              height: 44,
              child: const Icon(Icons.my_location_rounded, color: Colors.blue, size: 36),
            ),
          );

          // Add Markers for Lost & Found Posts
          for (final post in posts) {
            final double lat = post.latitude != 0.0 ? post.latitude : (23.8103 + (post.id.hashCode % 100) * 0.001);
            final double lng = post.longitude != 0.0 ? post.longitude : (90.4125 + (post.id.hashCode % 80) * 0.001);
            final bool isLost = post.type == 'lost';

            markers.add(
              Marker(
                point: ll.LatLng(lat, lng),
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => context.push('/item-details/${post.id}'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isLost ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Icon(
                      isLost ? Icons.search_rounded : Icons.check_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation,
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_lost_and_found',
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),

              if (_isLoadingLocation)
                const Positioned(
                  top: 16,
                  left: 20,
                  right: 20,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 12),
                          Text('Locating GPS position...', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${posts.length} Items Displayed on Map', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const Text('Red = Lost • Green = Found • Tap marker for details', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Map load error: $err')),
      ),
    );
  }
}
