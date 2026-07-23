import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    }
  }

  // ─────────────────────────────────────────────
  // Google Sign In (google_sign_in v7 API)
  // ─────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (_) {
      return null;
    }
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
