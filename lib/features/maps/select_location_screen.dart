import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/utils/location_utils.dart';

class LocationSearchResult {
  final String title;
  final String subtitle;
  final double lat;
  final double lng;

  const LocationSearchResult({
    required this.title,
    required this.subtitle,
    required this.lat,
    required this.lng,
  });
}

class SelectLocationScreen extends ConsumerStatefulWidget {
  final String? initialLocation;

  const SelectLocationScreen({super.key, this.initialLocation});

  @override
  ConsumerState<SelectLocationScreen> createState() =>
      _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  ll.LatLng _selectedLatLng = const ll.LatLng(
    23.7461,
    90.3742,
  ); // Default to Dhanmondi, Dhaka
  String _address = 'Dhanmondi, Dhaka';
  bool _isGeocoding = false;
  bool _isSearching = false;
  List<LocationSearchResult> _searchResults = [];
  bool _showSearchResults = false;

  // Preset popular locations in Bangladesh for instant offline / fallback search
  static const List<Map<String, dynamic>> _presetLocations = [
    {
      'name': 'Dhanmondi, Dhaka',
      'lat': 23.7461,
      'lng': 90.3742,
      'sub': 'Dhanmondi Lake & 27 Road area',
    },
    {
      'name': 'TSC, Dhaka University',
      'lat': 23.7323,
      'lng': 90.3957,
      'sub': 'Teacher-Student Centre, DU',
    },
    {
      'name': 'Curzon Hall, Dhaka',
      'lat': 23.7265,
      'lng': 90.4005,
      'sub': 'Science Faculty, DU',
    },
    {
      'name': 'Gulshan 1, Dhaka',
      'lat': 23.7797,
      'lng': 90.4162,
      'sub': 'Gulshan Circle 1 DCC Market',
    },
    {
      'name': 'Gulshan 2, Dhaka',
      'lat': 23.7949,
      'lng': 90.4143,
      'sub': 'Gulshan Circle 2 Hub',
    },
    {
      'name': 'Banani, Dhaka',
      'lat': 23.7937,
      'lng': 90.4047,
      'sub': 'Road 11 & Kemal Ataturk Ave',
    },
    {
      'name': 'Uttara, Dhaka',
      'lat': 23.8759,
      'lng': 90.3795,
      'sub': 'Sector 3 & 7 Rajlakshmi',
    },
    {
      'name': 'Mirpur 10, Dhaka',
      'lat': 23.8069,
      'lng': 90.3687,
      'sub': 'Mirpur 10 Metro Station',
    },
    {
      'name': 'Farmgate, Dhaka',
      'lat': 23.7561,
      'lng': 90.3872,
      'sub': 'Ananda Cinema & Metro Station',
    },
    {
      'name': 'Shahbagh, Dhaka',
      'lat': 23.7388,
      'lng': 90.3961,
      'sub': 'BSMMU & National Museum',
    },
    {
      'name': 'Motijheel, Dhaka',
      'lat': 23.7330,
      'lng': 90.4172,
      'sub': 'Commercial Area & Shapla Chattar',
    },
    {
      'name': 'Bashundhara R/A, Dhaka',
      'lat': 23.8191,
      'lng': 90.4326,
      'sub': 'NSU, IUB & Apollo Hospital area',
    },
    {
      'name': 'Mohammadpur, Dhaka',
      'lat': 23.7658,
      'lng': 90.3585,
      'sub': 'Town Hall & Japan Garden City',
    },
    {
      'name': 'Lalmatia, Dhaka',
      'lat': 23.7554,
      'lng': 90.3712,
      'sub': 'Block D & College area',
    },
    {
      'name': 'GEC Circle, Chattogram',
      'lat': 22.3592,
      'lng': 91.8215,
      'sub': 'GEC More, Chittagong',
    },
    {
      'name': 'Zindabazar, Sylhet',
      'lat': 24.8949,
      'lng': 91.8687,
      'sub': 'Zindabazar City Center',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null && widget.initialLocation!.isNotEmpty) {
      _address = widget.initialLocation!;
      _searchController.text = widget.initialLocation!;
      _performSearch(widget.initialLocation!, isInitial: true);
    } else {
      _getUserLocation();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      setState(() => _isGeocoding = true);
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isGeocoding = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isGeocoding = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 7),
      );

      final newPoint = ll.LatLng(position.latitude, position.longitude);
      _mapController.move(newPoint, 15);
      await _selectPoint(newPoint);
    } catch (_) {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  Future<void> _selectPoint(ll.LatLng point, [String? presetName]) async {
    setState(() {
      _selectedLatLng = point;
      _showSearchResults = false;
      if (presetName != null) {
        _address = presetName;
        _searchController.text = presetName;
      } else {
        _isGeocoding = true;
      }
    });

    if (presetName == null) {
      await _reverseGeocode(point);
    }
  }

  Future<void> _reverseGeocode(ll.LatLng point) async {
    // Check preset match first
    for (final p in _presetLocations) {
      final double dist = LocationUtils.calculateHaversineDistance(
        point.latitude,
        point.longitude,
        p['lat'],
        p['lng'],
      );
      if (dist < 0.3) {
        if (mounted) {
          setState(() {
            _address = p['name'];
            _searchController.text = p['name'];
            _isGeocoding = false;
          });
        }
        return;
      }
    }

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&zoom=18&addressdetails=1',
      );
      final response = await http
          .get(url, headers: {'User-Agent': 'FlutterLostAndFoundApp/1.0'})
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addr = data['address'] as Map<String, dynamic>?;
        if (addr != null) {
          final String road =
              addr['road'] ??
              addr['pedestrian'] ??
              addr['suburb'] ??
              addr['neighbourhood'] ??
              '';
          final String district =
              addr['city'] ??
              addr['town'] ??
              addr['county'] ??
              addr['state_district'] ??
              'Dhaka';
          final String fullAddr = road.isNotEmpty
              ? '$road, $district'
              : (data['display_name'] ?? '$district, Bangladesh');

          final formattedName = fullAddr.split(',').take(3).join(',').trim();

          if (mounted) {
            setState(() {
              _address = formattedName.isNotEmpty
                  ? formattedName
                  : 'Selected Spot (${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)})';
              _searchController.text = _address;
              _isGeocoding = false;
            });
          }
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _address =
            'Spot near ${LocationUtils.formatCoordinates(point.latitude, point.longitude)}';
        _isGeocoding = false;
      });
    }
  }

  Future<void> _performSearch(String query, {bool isInitial = false}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final List<LocationSearchResult> list = [];

    // 1. Filter local presets
    for (final p in _presetLocations) {
      final name = p['name'].toString();
      final sub = p['sub'].toString();
      if (name.toLowerCase().contains(q) || sub.toLowerCase().contains(q)) {
        list.add(
          LocationSearchResult(
            title: name,
            subtitle: sub,
            lat: p['lat'],
            lng: p['lng'],
          ),
        );
      }
    }

    // 2. Query Nominatim API for live Bangladesh location match
    try {
      final searchUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&countrycodes=bd&addressdetails=1',
      );
      final res = await http
          .get(searchUrl, headers: {'User-Agent': 'FlutterLostAndFoundApp/1.0'})
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        for (final item in data) {
          final double lat =
              double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final double lng =
              double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
          final String displayName = item['display_name'] ?? '';
          if (lat != 0.0 && lng != 0.0 && displayName.isNotEmpty) {
            final parts = displayName.split(',');
            final title = parts.take(2).join(',').trim();
            final subtitle = parts.skip(2).take(3).join(',').trim();
            if (!list.any(
              (e) => (e.lat - lat).abs() < 0.001 && (e.lng - lng).abs() < 0.001,
            )) {
              list.add(
                LocationSearchResult(
                  title: title,
                  subtitle: subtitle.isNotEmpty ? subtitle : 'Bangladesh',
                  lat: lat,
                  lng: lng,
                ),
              );
            }
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _searchResults = list;
        _showSearchResults = list.isNotEmpty && !isInitial;
        _isSearching = false;
      });

      if (isInitial && list.isNotEmpty) {
        final top = list.first;
        _mapController.move(ll.LatLng(top.lat, top.lng), 15);
        _selectPoint(ll.LatLng(top.lat, top.lng), top.title);
      }
    }
  }

  void _confirmAndReturn() {
    final resultData = {
      'address': _address,
      'lat': _selectedLatLng.latitude,
      'lng': _selectedLatLng.longitude,
    };
    context.pop(resultData);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. LIVE MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLatLng,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                _selectPoint(point);
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
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Icon(
                          Icons.location_pin,
                          color: AppColors.error,
                          size: 44,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. TOP HEADER & SEARCH BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
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
                            decoration: InputDecoration(
                              hintText:
                                  'Search place (e.g. Dhanmondi, Dhaka)...',
                              hintStyle: const TextStyle(fontSize: 13),
                              border: InputBorder.none,
                              suffixIcon: _isSearching
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : (_searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                _searchResults = [];
                                                _showSearchResults = false;
                                              });
                                            },
                                          )
                                        : null),
                            ),
                            onChanged: (val) => _performSearch(val),
                            onSubmitted: (val) => _performSearch(val),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                          ),
                          onPressed: () =>
                              _performSearch(_searchController.text),
                        ),
                      ],
                    ),
                  ),

                  // LIVE SEARCH SUGGESTIONS OVERLAY
                  if (_showSearchResults && _searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              final point = ll.LatLng(item.lat, item.lng);
                              _mapController.move(point, 15);
                              _selectPoint(point, item.title);
                            },
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 10),

                  // POPULAR PRESET LOCATION CHIPS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _presetLocations.take(7).map((p) {
                        final String name = p['name'].toString();
                        final double lat = p['lat'];
                        final double lng = p['lng'];
                        final bool isSel =
                            (_selectedLatLng.latitude - lat).abs() < 0.005 &&
                            (_selectedLatLng.longitude - lng).abs() < 0.005;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () {
                              final point = ll.LatLng(lat, lng);
                              _mapController.move(point, 15);
                              _selectPoint(point, name);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.darkSurface
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.primary
                                      : AppColors.outlineVariant.withOpacity(
                                          0.5,
                                        ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                name.split(',').first,
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
                ],
              ),
            ),
          ),

          // 3. FLOATING MY GPS LOCATION BUTTON
          Positioned(
            right: 16,
            bottom: 175,
            child: FloatingActionButton.small(
              heroTag: 'my_loc_btn',
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              onPressed: _getUserLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // 4. BOTTOM CONFIRMATION CARD
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.pin_drop_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Selected Report Spot:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.outline,
                          ),
                        ),
                        const Spacer(),
                        if (_isGeocoding)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _address,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocationUtils.formatCoordinates(
                        _selectedLatLng.latitude,
                        _selectedLatLng.longitude,
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Confirm Location',
                      icon: Icons.check_circle_rounded,
                      onPressed: _confirmAndReturn,
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
