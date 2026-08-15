import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthService() {
    _initPersistence();
  }

  Future<void> _initPersistence() async {
    if (kIsWeb) {
      try {
        await _auth.setPersistence(Persistence.LOCAL);
      } catch (_) {
        try {
          await _auth.setPersistence(Persistence.SESSION);
        } catch (_) {
          try {
            await _auth.setPersistence(Persistence.NONE);
          } catch (_) {}
        }
      }
    }
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─────────────────────────────────────────────
  // Email & Password Sign Up
  // ─────────────────────────────────────────────
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      // Handle browser IndexedDB storage error
      if (kIsWeb && e.toString().contains('indexedDB')) {
        try {
          await _auth.setPersistence(Persistence.NONE);
          return await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (_) {}
      }
      throw 'রেজিস্ট্রেশন করতে সমস্যা হচ্ছে। কিছুক্ষণ পরে চেষ্টা করুন।';
    }
  }

  // ─────────────────────────────────────────────
  // Email & Password Sign In
  // ─────────────────────────────────────────────
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      if (kIsWeb && e.toString().contains('indexedDB')) {
        try {
          await _auth.setPersistence(Persistence.NONE);
          return await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (_) {}
      }
      throw 'লগইন করতে সমস্যা হচ্ছে। তথ্য পরীক্ষা করুন।';
    }
  }

  // ─────────────────────────────────────────────
  // Google Sign In (google_sign_in v7 API)
  // ─────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await _auth.signInWithPopup(googleProvider);
      }

      const clientId =
          '779298287833-apkicde2h99c79olnea347540ol3rkv5.apps.googleusercontent.com';
      await GoogleSignIn.instance.initialize(serverClientId: clientId);

      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw 'Google ID Token is null. Check Firebase OAuth configuration.';
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled') {
        return null;
      }
      throw _handleFirebaseError(e);
    } catch (e) {
      print('Google Sign In Error: $e');
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled') ||
          e.toString().contains('popup-closed-by-user')) {
        return null;
      }
      throw 'গুগল দিয়ে সাইন-ইন করতে সমস্যা হচ্ছে: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}';
    }
  }

  /// Sign in with Google and ensure a Firestore user profile exists.
  /// Preserves existing user roles (admin, author, campus_admin, user) and profile data if user already exists.
  Future<UserCredential?> signInWithGoogleAndSyncProfile(
    FirestoreService firestoreService,
  ) async {
    final cred = await signInWithGoogle();
    if (cred != null && cred.user != null) {
      final user = cred.user!;
      try {
        final existingUser = await firestoreService.getUser(user.uid);
        if (existingUser == null) {
          // Create profile for new Google user with default role 'user'
          final newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName?.isNotEmpty == true
                ? user.displayName!
                : 'User',
            photoUrl: user.photoURL ?? '',
            phoneNumber: user.phoneNumber ?? '',
            role: 'user',
            isNidVerified: false,
            rewardPoints: 0,
            location: 'Dhaka, Bangladesh',
            createdAt: DateTime.now(),
          );
          await firestoreService.saveUser(newUser);
        }
      } catch (e) {
        print('Firestore user profile sync warning: $e');
      }
    }
    return cred;
  }

  // ─────────────────────────────────────────────
  // Phone OTP
  // ─────────────────────────────────────────────
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    try {
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // ─────────────────────────────────────────────
  // Password Reset
  // ─────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    }
  }

  // ─────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────
  // Human-readable Firebase error messages (Bangla-friendly)
  // ─────────────────────────────────────────────
  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'এই ইমেইল দিয়ে কোনো একাউন্ট পাওয়া যায়নি। নতুন একাউন্ট তৈরি করুন।';
      case 'wrong-password':
        return 'পাসওয়ার্ড সঠিক নয়। আবার চেষ্টা করুন।';
      case 'invalid-credential':
        return 'ইমেইল বা পাসওয়ার্ড সঠিক নয়। আবার চেষ্টা করুন।';
      case 'email-already-in-use':
        return 'এই ইমেইল দিয়ে ইতিমধ্যে একটি একাউন্ট আছে।';
      case 'invalid-email':
        return 'ইমেইল ঠিকানাটি সঠিক নয়।';
      case 'weak-password':
        return 'পাসওয়ার্ড খুব দুর্বল। কমপক্ষে ৬ অক্ষর ব্যবহার করুন।';
      case 'user-disabled':
        return 'এই একাউন্টটি নিষ্ক্রিয় করা হয়েছে।';
      case 'too-many-requests':
        return 'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।';
      case 'network-request-failed':
        return 'ইন্টারনেট সংযোগ পরীক্ষা করুন এবং আবার চেষ্টা করুন।';
      case 'operation-not-allowed':
        return 'এই লগইন পদ্ধতি এখন সক্রিয় নয়।';
      default:
        return e.message ?? 'একটি সমস্যা হয়েছে। আবার চেষ্টা করুন।';
    }
  }
}
