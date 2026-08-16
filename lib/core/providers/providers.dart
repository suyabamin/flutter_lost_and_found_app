import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

// Theme State Provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

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
