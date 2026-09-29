import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

import '../services/cloudinary_service.dart';

import '../models/recovery_models.dart';

import '../models/campus_models.dart';
import '../models/report_model.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);
final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (ref) => CloudinaryService(),
);

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Current User Stream
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);
  return ref.watch(firestoreServiceProvider).streamUser(authUser.uid);
});

// Persistent Theme Notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _prefKey = 'app_theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt(_prefKey);
      if (savedIndex != null &&
          savedIndex >= 0 &&
          savedIndex < ThemeMode.values.length) {
        state = ThemeMode.values[savedIndex];
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, mode.index);
    } catch (_) {}
  }

  set stateValue(ThemeMode mode) => setThemeMode(mode);
}

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  return ThemeNotifier();
});

// ── Persistent Locale Notifier ─────────────────────────────────────────────
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _prefKey = 'app_locale';

  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null) {
        state = Locale(saved);
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, locale.languageCode);
    } catch (_) {}
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// Category Filter Provider
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Post Type Filter Provider (All, Lost, Found)
final selectedPostTypeProvider = StateProvider<String?>((ref) => null);

// Posts Stream Provider
final postsStreamProvider = StreamProvider<List<PostModel>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final type = ref.watch(selectedPostTypeProvider);
  return ref
      .watch(firestoreServiceProvider)
      .streamPosts(category: category, type: type);
});

// Platform-Wide History Stream Provider
final allHistoryStreamProvider = StreamProvider<List<HistoryModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamAllHistory();
});

// Raw All Posts Stream Provider (unfiltered by status)
final rawAllPostsStreamProvider = StreamProvider<List<PostModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamRawAllPosts();
});

// User Posts Stream Provider (by userId)
final userPostsStreamProvider = StreamProvider.family<List<PostModel>, String>((
  ref,
  userId,
) {
  return ref.watch(firestoreServiceProvider).streamUserPosts(userId);
});

// Campus Providers
final selectedCampusProvider = StateProvider<CampusModel?>((ref) => null);

final allCampusesStreamProvider = StreamProvider<List<CampusModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamAllCampuses();
});

final userCampusMembershipsProvider = StreamProvider<List<CampusMemberModel>>((
  ref,
) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(firestoreServiceProvider)
      .streamUserCampusMemberships(user.uid);
});

final campusPostsStreamProvider =
    StreamProvider.family<List<PostModel>, String>((ref, campusId) {
      return ref.watch(firestoreServiceProvider).streamCampusPosts(campusId);
    });

final campusMembersStreamProvider =
    StreamProvider.family<List<CampusMemberModel>, String>((ref, campusId) {
      return ref.watch(firestoreServiceProvider).streamCampusMembers(campusId);
    });

// ── Report Providers (additive) ──────────────────────────────────────────────

/// Streams all reports (newest first, page size 20) for the admin screen.
final reportsStreamProvider = StreamProvider<List<ReportModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamReports();
});

/// Streams reports filtered by status string (e.g. 'pending', 'reviewing').
/// Pass 'All' or empty to stream every report.
final reportsByStatusProvider =
    StreamProvider.family<List<ReportModel>, String>((ref, status) {
      return ref
          .watch(firestoreServiceProvider)
          .streamReports(status: status == 'All' ? null : status);
    });

/// Streams the total pending-report count for the Admin Dashboard stat card.
final pendingReportCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(firestoreServiceProvider)
      .streamReportCount(status: 'pending');
});

// ── Persistent Push Notifications Setting Notifier ────────────────────────
class PushNotificationsNotifier extends StateNotifier<bool> {
  static const String _prefKey = 'app_push_notifications';

  PushNotificationsNotifier() : super(true) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_prefKey);
      if (saved != null) {
        state = saved;
      }
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enabled);
    } catch (_) {}
  }
}

final pushNotificationsProvider =
    StateNotifierProvider<PushNotificationsNotifier, bool>((ref) {
  return PushNotificationsNotifier();
});

// ── Persistent Saved Favorites Notifier ──────────────────────────────────
class FavoritesNotifier extends StateNotifier<Set<String>> {
  static const String _prefKey = 'app_favorite_post_ids';

  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(_prefKey) ?? [];
      state = savedList.toSet();
    } catch (_) {}
  }

  Future<bool> toggleFavorite(String postId) async {
    final newSet = Set<String>.from(state);
    bool isAdded = false;
    if (newSet.contains(postId)) {
      newSet.remove(postId);
    } else {
      newSet.add(postId);
      isAdded = true;
    }
    state = newSet;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, newSet.toList());
    } catch (_) {}
    return isAdded;
  }

  bool isFavorite(String postId) {
    return state.contains(postId);
  }
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

/// Streams total user count for Admin Dashboard
final totalUserCountProvider = StreamProvider<int>((ref) {
  return ref.watch(firestoreServiceProvider).streamTotalUserCount();
});

/// Streams total post count for Admin Dashboard
final totalPostCountProvider = StreamProvider<int>((ref) {
  return ref.watch(firestoreServiceProvider).streamTotalPostCount();
});

