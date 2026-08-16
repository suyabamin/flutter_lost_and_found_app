import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';
import '../utils/location_utils.dart';
import 'providers.dart';

enum LiveTrackingStatus { stopped, active, paused }

class LiveLocationState {
  final LiveTrackingStatus trackingStatus;
  final double latitude;
  final double longitude;
  final double accuracy;
  final String address;
  final DateTime? lastUpdated;
  final bool isGpsEnabled;
  final bool hasPermission;
  final String? errorMessage;

  const LiveLocationState({
    this.trackingStatus = LiveTrackingStatus.stopped,
    this.latitude = 23.8103,
    this.longitude = 90.4125,
    this.accuracy = 0.0,
    this.address = 'Dhaka, Bangladesh',
    this.lastUpdated,
    this.isGpsEnabled = true,
    this.hasPermission = true,
    this.errorMessage,
  });

  LiveLocationState copyWith({
    LiveTrackingStatus? trackingStatus,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? address,
    DateTime? lastUpdated,
    bool? isGpsEnabled,
    bool? hasPermission,
    String? errorMessage,
  }) {
    return LiveLocationState(
      trackingStatus: trackingStatus ?? this.trackingStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      address: address ?? this.address,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
      hasPermission: hasPermission ?? this.hasPermission,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LiveLocationNotifier extends StateNotifier<LiveLocationState> {
  StreamSubscription<Position>? _positionSubscription;

  LiveLocationNotifier() : super(const LiveLocationState()) {
    _loadCachedLocation();
    checkGpsAndPermissions();
  }

  Future<void> _loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('cached_lat');
      final lng = prefs.getDouble('cached_lng');
      if (lat != null && lng != null) {
        state = state.copyWith(
          latitude: lat,
          longitude: lng,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (_) {}
  }

  Future<void> _cacheLocation(double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cached_lat', lat);
      await prefs.setDouble('cached_lng', lng);
    } catch (_) {}
  }

  Future<bool> checkGpsAndPermissions() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isGpsEnabled: false,
          errorMessage: 'GPS service disabled',
        );
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            hasPermission: false,
            errorMessage: 'Location permission denied',
          );
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          hasPermission: false,
          errorMessage: 'Location permissions permanently denied',
        );
        return false;
      }

      state = state.copyWith(
        isGpsEnabled: true,
        hasPermission: true,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refreshCurrentLocation() async {
    final ready = await checkGpsAndPermissions();
    if (!ready) return;

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      await _cacheLocation(pos.latitude, pos.longitude);

      state = state.copyWith(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        lastUpdated: DateTime.now(),
        isGpsEnabled: true,
        hasPermission: true,
        errorMessage: null,
      );
    } catch (_) {
      // Fall back silently to last state
    }
  }

  Future<void> enableLiveLocation() async {
    final ready = await checkGpsAndPermissions();
    if (!ready) return;

    await refreshCurrentLocation();
    _stopListening();

    state = state.copyWith(trackingStatus: LiveTrackingStatus.active);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters movement
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            _cacheLocation(position.latitude, position.longitude);
            state = state.copyWith(
              latitude: position.latitude,
              longitude: position.longitude,
              accuracy: position.accuracy,
              lastUpdated: DateTime.now(),
              trackingStatus: LiveTrackingStatus.active,
              isGpsEnabled: true,
              hasPermission: true,
            );
          },
          onError: (err) {
            state = state.copyWith(errorMessage: err.toString());
          },
        );
  }

  void pauseLiveLocation() {
    _stopListening();
    state = state.copyWith(trackingStatus: LiveTrackingStatus.paused);
  }

  void stopLiveLocation() {
    _stopListening();
    state = state.copyWith(trackingStatus: LiveTrackingStatus.stopped);
  }

  void _stopListening() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}

class RadiusSearchState {
  final double radiusKm;
  final bool isEnabled;
  final String sortOption; // 'Nearest', 'Newest', 'Reward', 'AI Match'
  final String? filterType; // null for all, 'lost', 'found'
  final String? selectedPostId;
  final String searchQuery;

  const RadiusSearchState({
    this.radiusKm = 5.0,
    this.isEnabled = true,
    this.sortOption = 'Nearest',
    this.filterType,
    this.selectedPostId,
    this.searchQuery = '',
  });

  RadiusSearchState copyWith({
    double? radiusKm,
    bool? isEnabled,
    String? sortOption,
    String? filterType,
    String? selectedPostId,
    String? searchQuery,
    bool clearSelectedPost = false,
  }) {
    return RadiusSearchState(
      radiusKm: radiusKm ?? this.radiusKm,
      isEnabled: isEnabled ?? this.isEnabled,
      sortOption: sortOption ?? this.sortOption,
      filterType: filterType ?? this.filterType,
      selectedPostId: clearSelectedPost
          ? null
          : (selectedPostId ?? this.selectedPostId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class RadiusSearchNotifier extends StateNotifier<RadiusSearchState> {
  RadiusSearchNotifier() : super(const RadiusSearchState());

  void setRadius(double radiusKm) {
    state = state.copyWith(radiusKm: radiusKm);
  }

  void toggleEnabled(bool enabled) {
    state = state.copyWith(isEnabled: enabled);
  }

  void setSortOption(String sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void setFilterType(String? type) {
    state = state.copyWith(filterType: type);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectPost(String? postId) {
    if (postId == null) {
      state = state.copyWith(clearSelectedPost: true);
    } else {
      state = state.copyWith(selectedPostId: postId);
    }
  }
}

// RIVERPOD PROVIDERS
final liveLocationProvider =
    StateNotifierProvider<LiveLocationNotifier, LiveLocationState>((ref) {
      return LiveLocationNotifier();
    });

final radiusSearchProvider =
    StateNotifierProvider<RadiusSearchNotifier, RadiusSearchState>((ref) {
      return RadiusSearchNotifier();
    });

class PostWithDistance {
  final PostModel post;
  final double distanceKm;

  PostWithDistance({required this.post, required this.distanceKm});
}

final filteredRadiusPostsProvider = Provider<List<PostWithDistance>>((ref) {
  final postsAsync = ref.watch(postsStreamProvider);
  final liveLoc = ref.watch(liveLocationProvider);
  final radiusState = ref.watch(radiusSearchProvider);
  final category = ref.watch(selectedCategoryProvider);
  final globalType = ref.watch(selectedPostTypeProvider);

  final posts = postsAsync.value ?? <PostModel>[];

  final List<PostWithDistance> listWithDistance = [];
  final String query = radiusState.searchQuery.trim().toLowerCase();

  for (final post in posts) {
    // 0. Active Status Filter: Remove completed/found/archived items from map
    if (post.status == 'completed' ||
        post.status == 'resolved' ||
        post.status == 'archived' ||
        post.status == 'closed') {
      continue;
    }

    // 1. Text Search Filter (Title, Description, Category, Location)
    if (query.isNotEmpty) {
      final matchesTitle = post.title.toLowerCase().contains(query);
      final matchesDesc = post.description.toLowerCase().contains(query);
      final matchesLoc = post.location.toLowerCase().contains(query);
      final matchesCat = post.category.toLowerCase().contains(query);
      if (!matchesTitle && !matchesDesc && !matchesLoc && !matchesCat) {
        continue;
      }
    }

    // 2. Category Filter
    if (category != 'All' && post.category != category) {
      continue;
    }

    // 3. Type Filter (Lost / Found)
    final activeType = radiusState.filterType ?? globalType;
    if (activeType != null && activeType.isNotEmpty && activeType != 'All') {
      if (post.type != activeType.toLowerCase()) {
        continue;
      }
    }

    // 4. Safe Coordinate Check (skip invalid coordinates safely)
    final double lat = post.latitude;
    final double lng = post.longitude;
    final bool isValidCoords =
        lat >= -90.0 && lat <= 90.0 && lng >= -180.0 && lng <= 180.0;
    if (!isValidCoords) {
      continue;
    }

    // 5. Distance Calculation
    final double distKm = LocationUtils.calculateHaversineDistance(
      liveLoc.latitude,
      liveLoc.longitude,
      lat,
      lng,
    );

    // 6. Radius Filter
    if (radiusState.isEnabled && distKm > radiusState.radiusKm) {
      continue;
    }

    listWithDistance.add(PostWithDistance(post: post, distanceKm: distKm));
  }

  // 7. Sorting
  if (radiusState.sortOption == 'Nearest') {
    listWithDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  } else if (radiusState.sortOption == 'Newest') {
    listWithDistance.sort(
      (a, b) => b.post.createdAt.compareTo(a.post.createdAt),
    );
  } else if (radiusState.sortOption == 'Reward') {
    listWithDistance.sort(
      (a, b) => b.post.rewardAmount.compareTo(a.post.rewardAmount),
    );
  } else if (radiusState.sortOption == 'AI Match') {
    listWithDistance.sort(
      (a, b) => b.post.similarityScore.compareTo(a.post.similarityScore),
    );
  }

  return listWithDistance;
});
