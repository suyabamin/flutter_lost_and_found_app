import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

import '../services/cloudinary_service.dart';

// Services
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) => CloudinaryService());

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
  return ref.watch(firestoreServiceProvider).streamPosts(
        category: category,
        type: type,
      );
});
