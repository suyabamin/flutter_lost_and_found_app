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
  final TextEditingController _searchController = TextEditingController();

  ll.LatLng _currentLocation = const ll.LatLng(23.8103, 90.4125);
  bool _isLoadingLocation = true;
  bool _isListView = false;

  static const List<double> _radiusPresetsKm = [
    1.0,
    2.0,
    5.0,
    10.0,
    25.0,
    50.0,
    100.0,
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _recenterMap(ll.LatLng point, double zoom) {
    try {
      _mapController.move(point, zoom);
    } catch (_) {}
  }

  void _zoomIn() {
    try {
      final currentZoom = _mapController.camera.zoom;
      _mapController.move(_mapController.camera.center, currentZoom + 1);
    } catch (_) {}
  }

  void _zoomOut() {
    try {
      final currentZoom = _mapController.camera.zoom;
      _mapController.move(_mapController.camera.center, currentZoom - 1);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final liveState = ref.watch(liveLocationProvider);
    final radiusState = ref.watch(radiusSearchProvider);
    final radiusNotifier = ref.read(radiusSearchProvider.notifier);
    final nearbyPostsWithDistance = ref.watch(filteredRadiusPostsProvider);

    final userLatLng = ll.LatLng(liveState.latitude, liveState.longitude);

    return Scaffold(
      body: Stack(
        children: [
          // 1. MAP VIEW OR LIST VIEW CONTENT
          _isListView
              ? _buildListViewContent(
                  context,
                  nearbyPostsWithDistance,
                  radiusState,
                  radiusNotifier,
                  isDark,
                )
              : _buildMapViewContent(
                  context,
                  userLatLng,
                  nearbyPostsWithDistance,
                  radiusState,
                  radiusNotifier,
                ),

          // 2. TOP FLOATING HEADER (SEARCH + MAP/LIST TOGGLE)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search items (e.g. iPhone, Keys)...',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.outline,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    radiusNotifier.setSearchQuery('');
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          radiusNotifier.setSearchQuery(val);
                          setState(() {});
                        },
                      ),
                    ),

                    // MAP / LIST TOGGLE SEGMENT
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => setState(() => _isListView = false),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: !_isListView
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.map_rounded,
                                    size: 16,
                                    color: !_isListView
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Map',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: !_isListView
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _isListView = true),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _isListView
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.format_list_bulleted_rounded,
                                    size: 16,
                                    color: _isListView
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'List',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _isListView
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),

          // 3. FLOATING MAP ACTION BUTTONS (MY LOCATION, ZOOM IN, ZOOM OUT)
          if (!_isListView)
            Positioned(
              right: 16,
              bottom: 235,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'my_gps_btn',
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : Colors.white,
                    foregroundColor:
                        liveState.trackingStatus == LiveTrackingStatus.active
                        ? Colors.green
                        : AppColors.primary,
                    elevation: 4,
                    tooltip: 'Center My Location',
                    onPressed: () {
                      _recenterMap(userLatLng, 14.5);
                    },
                    child: Icon(
                      liveState.trackingStatus == LiveTrackingStatus.active
                          ? Icons.sensors_rounded
                          : Icons.my_location_rounded,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_in_btn',
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : Colors.white,
                    foregroundColor: AppColors.onSurface,
                    elevation: 4,
                    tooltip: 'Zoom In',
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add_rounded),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out_btn',
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : Colors.white,
                    foregroundColor: AppColors.onSurface,
                    elevation: 4,
                    tooltip: 'Zoom Out',
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove_rounded),
                  ),
                ],
              ),
            ),

          // 4. GPS LOADING BADGE OVERLAY
          if (_isLoadingLocation && !_isListView)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. EMPTY STATE OVERLAY (NO ITEMS FOUND NEARBY)
          if (nearbyPostsWithDistance.isEmpty && !_isLoadingLocation)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.radar_rounded,
                            color: AppColors.outline,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'No items found nearby',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        radiusState.isEnabled
                            ? 'No items reported within ${LocationUtils.formatDistance(radiusState.radiusKm)} radius.'
                            : 'No items match your active search filter.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () {
                          final double nextRadius = radiusState.radiusKm < 5
                              ? 5.0
                              : (radiusState.radiusKm < 10
                                    ? 10.0
                                    : (radiusState.radiusKm < 25
                                          ? 25.0
                                          : 50.0));
                          radiusNotifier.setRadius(nextRadius);
                        },
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 16,
                        ),
                        label: Text(
                          'Increase Radius (${LocationUtils.formatDistance(radiusState.radiusKm < 5 ? 5.0 : radiusState.radiusKm + 5)})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 6. BOTTOM CONTROL OVERLAY WITH RADIUS PRESETS & SLIDER
          Positioned(
            bottom: 16,
            left: 14,
            right: 14,
            child: GlassContainer(
              borderRadius: 22,
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.radar_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${nearbyPostsWithDistance.length} Items within ${LocationUtils.formatDistance(radiusState.radiusKm)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: radiusState.isEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (val) => radiusNotifier.toggleEnabled(val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Quick distance chips on map
                  if (radiusState.isEnabled) ...[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _radiusPresetsKm.map((km) {
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
                                      : (isDark
                                            ? AppColors.darkSurface
                                            : Colors.white.withOpacity(0.85)),
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
                                      : '${km.toInt()} KM',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSel
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.white
                                              : AppColors.onSurface),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapViewContent(
    BuildContext context,
    ll.LatLng userLatLng,
    List<PostWithDistance> nearbyPostsWithDistance,
    RadiusSearchState radiusState,
    RadiusSearchNotifier radiusNotifier,
  ) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: userLatLng,
        initialZoom: 13.5,
        onTap: (_, __) {
          radiusNotifier.selectPost(null);
        },
      ),
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
                color: AppColors.primary.withOpacity(0.12),
                borderColor: AppColors.primary,
                borderStrokeWidth: 2.2,
              ),
            ],
          ),

        // MARKER LAYER
        MarkerLayer(
          markers: [
            // User Current GPS Location Pulse Marker
            Marker(
              point: userLatLng,
              width: 52,
              height: 52,
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
              (() {
                final post = itemWithDist.post;
                final double lat = post.latitude;
                final double lng = post.longitude;
                final bool isLost = post.type == 'lost';
                final bool isSelected = radiusState.selectedPostId == post.id;

                final Color markerBg = isLost
                    ? AppColors.error
                    : AppColors.secondary;

                return Marker(
                  point: ll.LatLng(lat, lng),
                  width: isSelected ? 56 : 46,
                  height: isSelected ? 56 : 46,
                  child: GestureDetector(
                    onTap: () {
                      radiusNotifier.selectPost(post.id);
                      _recenterMap(ll.LatLng(lat, lng), 15);
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
                          color: isSelected ? Colors.amber : Colors.white,
                          width: isSelected ? 3.5 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? Colors.amber.withOpacity(0.8)
                                : Colors.black26,
                            blurRadius: isSelected ? 14 : 4,
                            spreadRadius: isSelected ? 3 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        isLost
                            ? Icons.search_rounded
                            : Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: isSelected ? 30 : 24,
                      ),
                    ),
                  ),
                );
              })(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildListViewContent(
    BuildContext context,
    List<PostWithDistance> nearbyPostsWithDistance,
    RadiusSearchState radiusState,
    RadiusSearchNotifier radiusNotifier,
    bool isDark,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 60, bottom: 120),
        child: nearbyPostsWithDistance.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off_rounded,
                        size: 48,
                        color: AppColors.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No items found within ${LocationUtils.formatDistance(radiusState.radiusKm)} radius.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try expanding your radius slider or clearing search keywords.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: nearbyPostsWithDistance.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final itemWithDist = nearbyPostsWithDistance[index];
                  final post = itemWithDist.post;
                  final isLost = post.type == 'lost';

                  return GestureDetector(
                    onTap: () => context.push('/item-details/${post.id}'),
                    child: GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.grey.shade200,
                              image: post.images.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(post.images.first),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLost
                                          ? AppColors.error
                                          : AppColors.secondary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isLost ? 'LOST' : 'FOUND',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        post.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.near_me_rounded,
                                            color: AppColors.primary,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            LocationUtils.formatDistance(
                                              itemWithDist.distanceKm,
                                            ),
                                            style: const TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  post.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.outline,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        post.location,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.outline,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (post.rewardAmount > 0) ...[
                                      Text(
                                        '৳${post.rewardAmount.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
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
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isLost
                                ? AppColors.error
                                : AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            post.category,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
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
                    const SizedBox(height: 6),
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (post.rewardAmount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Reward Offered: ৳${post.rewardAmount.toInt()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _recenterMap(ll.LatLng(post.latitude, post.longitude), 16);
                  },
                  child: const Text('Focus Pin'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
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
                    'View Details & Claim',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
