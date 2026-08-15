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
import '../../core/providers/location_dashboard_provider.dart';
import '../../core/utils/location_utils.dart';

class GoogleMapViewScreen extends ConsumerStatefulWidget {
  const GoogleMapViewScreen({super.key});

  @override
  ConsumerState<GoogleMapViewScreen> createState() =>
      _GoogleMapViewScreenState();
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
      final notifier = ref.read(liveLocationProvider.notifier);
      final ready = await notifier.checkGpsAndPermissions();
      if (!ready) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      await notifier.refreshCurrentLocation();
      final liveState = ref.read(liveLocationProvider);

      if (mounted) {
        setState(() {
          _currentLocation = ll.LatLng(liveState.latitude, liveState.longitude);
          _isLoadingLocation = false;
        });

        _mapController.move(_currentLocation, 13.5);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveState = ref.watch(liveLocationProvider);
    final radiusState = ref.watch(radiusSearchProvider);
    final radiusNotifier = ref.read(radiusSearchProvider.notifier);
    final nearbyPostsWithDistance = ref.watch(filteredRadiusPostsProvider);

    final userLatLng = ll.LatLng(liveState.latitude, liveState.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Radius Search Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              liveState.trackingStatus == LiveTrackingStatus.active
                  ? Icons.sensors_rounded
                  : Icons.my_location_rounded,
              color: liveState.trackingStatus == LiveTrackingStatus.active
                  ? Colors.green
                  : null,
            ),
            tooltip: 'Center on My GPS Location',
            onPressed: () {
              _mapController.move(userLatLng, 14);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: userLatLng, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_lost_and_found',
              ),

              // SEARCH RADIUS CIRCLE ON MAP
              if (radiusState.isEnabled)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: userLatLng,
                      radius: radiusState.radiusKm * 1000, // radius in meters
                      useRadiusInMeter: true,
                      color: AppColors.primary.withOpacity(0.14),
                      borderColor: AppColors.primary,
                      borderStrokeWidth: 2.5,
                    ),
                  ],
                ),

              // MARKER LAYER
              MarkerLayer(
                markers: [
                  // User Current GPS Location Pulse Marker
                  Marker(
                    point: userLatLng,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.my_location_rounded,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                    ),
                  ),

                  // Nearby Active Posts Markers (Lost & Found items)
                  for (final itemWithDist in nearbyPostsWithDistance) ...[
                    if (itemWithDist.post.status != 'completed' &&
                        itemWithDist.post.status != 'resolved' &&
                        itemWithDist.post.status != 'archived' &&
                        itemWithDist.post.status != 'closed')
                      (() {
                        final post = itemWithDist.post;
                        final double lat = post.latitude != 0.0
                            ? post.latitude
                            : (23.8103 + (post.id.hashCode % 100) * 0.001);
                        final double lng = post.longitude != 0.0
                            ? post.longitude
                            : (90.4125 + (post.id.hashCode % 80) * 0.001);
                        final bool isLost = post.type == 'lost';
                        final bool isSelected =
                            radiusState.selectedPostId == post.id;

                        Color markerBg = isLost
                            ? AppColors.error
                            : AppColors.secondary;

                        return Marker(
                          point: ll.LatLng(lat, lng),
                          width: isSelected ? 54 : 44,
                          height: isSelected ? 54 : 44,
                          child: GestureDetector(
                            onTap: () {
                              radiusNotifier.selectPost(post.id);
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) => _buildPostPreviewSheet(
                                  context,
                                  post,
                                  itemWithDist.distanceKm,
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: markerBg,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white,
                                  width: isSelected ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? Colors.blue.withOpacity(0.6)
                                        : Colors.black26,
                                    blurRadius: isSelected ? 12 : 4,
                                    spreadRadius: isSelected ? 2 : 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isLost
                                    ? Icons.search_rounded
                                    : Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: isSelected ? 28 : 22,
                              ),
                            ),
                          ),
                        );
                      })(),
                  ],
                ],
              ),
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
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Locating GPS position...',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // BOTTOM CONTROL OVERLAY WITH RADIUS SLIDER
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.radar_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${nearbyPostsWithDistance.length} Items inside ${LocationUtils.formatDistance(radiusState.radiusKm)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => context.push('/search-results'),
                            child: const Text(
                              'List View',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Quick distance chips on map
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0].map((
                        km,
                      ) {
                        final bool isSel =
                            (radiusState.radiusKm - km).abs() < 0.1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => radiusNotifier.setRadius(km),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.primary
                                    : Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.primary
                                      : AppColors.outlineVariant,
                                ),
                              ),
                              child: Text(
                                km < 1.0
                                    ? '${(km * 1000).toInt()}m'
                                    : '${km.toInt()}KM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSel
                                      ? Colors.white
                                      : AppColors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Radius Slider
                  Row(
                    children: [
                      const Text(
                        'Radius:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 7,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: AppColors.primary,
                            thumbColor: AppColors.primary,
                          ),
                          child: Slider(
                            value: radiusState.radiusKm.clamp(0.5, 100.0),
                            min: 0.5,
                            max: 100.0,
                            divisions: 199,
                            onChanged: (val) => radiusNotifier.setRadius(val),
                          ),
                        ),
                      ),
                      Text(
                        LocationUtils.formatDistance(radiusState.radiusKm),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostPreviewSheet(
    BuildContext context,
    PostModel post,
    double distanceKm,
  ) {
    final bool isLost = post.type == 'lost';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                  image: post.images.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(post.images.first),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isLost
                                ? AppColors.error
                                : AppColors.secondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LocationUtils.formatDistance(distanceKm),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      post.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.push('/item-details/${post.id}');
              },
              child: const Text(
                'View Full Details & Claim',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
