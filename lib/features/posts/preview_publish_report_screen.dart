import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/app_image.dart';
import '../../core/models/post_model.dart';
import '../../core/providers/providers.dart';
import '../../core/services/firestore_service.dart';
import '../home_dashboard/home_dashboard_screen.dart';

class PreviewPublishReportScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? postData;

  const PreviewPublishReportScreen({super.key, this.postData});

  @override
  ConsumerState<PreviewPublishReportScreen> createState() =>
      _PreviewPublishReportScreenState();
}

class _PreviewPublishReportScreenState
    extends ConsumerState<PreviewPublishReportScreen> {
  bool _isPublishing = false;

  Future<void> _handlePublish() async {
    setState(() => _isPublishing = true);

    try {
      final user = ref.read(currentUserProvider).value;
      final data = widget.postData ?? {};

      final String title = data['title'] ?? 'Lost Item Report';
      final String description =
          data['description'] ?? 'No description provided.';
      final String category = data['category'] ?? 'Electronics';
      final String type = data['type'] ?? 'lost';
      final String location = data['location'] ?? 'Dhaka, Bangladesh';
      final double rewardAmount =
          (data['rewardAmount'] as num?)?.toDouble() ?? 0.0;
      final List<XFile> pickedFiles =
          (data['pickedFiles'] as List<XFile>?) ?? [];

      List<String> imageUrls = [];
      List<Uint8List> pickedBytes = [];

      // Read raw bytes from picked files for local display (bypasses all upload/encoding issues)
      if (pickedFiles.isNotEmpty) {
        pickedBytes = await Future.wait(
          pickedFiles.map((f) => f.readAsBytes()),
        );
      }

      // Convert or upload picked images for Firestore storage
      if (pickedFiles.isNotEmpty) {
        final cloudinaryService = ref.read(cloudinaryServiceProvider);
        imageUrls = await cloudinaryService.uploadMultipleXFiles(pickedFiles);
      } else {
        imageUrls = [
          'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/600/400',
        ];
      }

      final double latitude = (data['latitude'] as num?)?.toDouble() ?? 23.7461;
      final double longitude =
          (data['longitude'] as num?)?.toDouble() ?? 90.3742;

      final authUser = FirebaseAuth.instance.currentUser;

      final newPost = PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        category: category,
        type: type,
        location: location,
        latitude: latitude,
        longitude: longitude,
        date: 'Just now',
        images: imageUrls,
        userId:
            user?.uid ??
            authUser?.uid ??
            'guest_${DateTime.now().millisecondsSinceEpoch}',
        userName: (user?.displayName != null && user!.displayName.isNotEmpty)
            ? user.displayName
            : ((authUser?.displayName != null &&
                      authUser!.displayName!.isNotEmpty)
                  ? authUser.displayName!
                  : 'Anonymous User'),
        rewardAmount: rewardAmount,
      );

      // Save post to Cloud Firestore & Local Store
      await ref.read(firestoreServiceProvider).createPost(newPost);

      // Store raw image bytes so this device always shows the user's actual photo
      // (works even when Cloudinary isn't configured or images exceeded Base64 limits)
      if (pickedBytes.isNotEmpty) {
        FirestoreService.storeLocalImageBytes(newPost.id, pickedBytes);
      }

      // Invalidate stream providers so feed & stats refresh instantly
      ref.invalidate(postsStreamProvider);
      try {
        ref.invalidate(allPostsStreamProvider);
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Your report has been published successfully!'),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error publishing post: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.postData ?? {};
    final String title = data['title'] ?? 'Silver iPhone 14 Pro with blue case';
    final String description =
        data['description'] ??
        'Lost somewhere around Dhanmondi Road 27. Has a small scratch on bottom left edge.';
    final String category = data['category'] ?? 'Electronics';
    final String type = data['type'] ?? 'lost';
    final String location = data['location'] ?? 'Dhanmondi, Dhaka';
    final double rewardAmount =
        (data['rewardAmount'] as num?)?.toDouble() ?? 1000.0;
    final List<XFile> pickedFiles = (data['pickedFiles'] as List<XFile>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: AppImage(
                url: pickedFiles.isNotEmpty
                    ? pickedFiles.first.path
                    : 'https://picsum.photos/seed/iphone14/600/400',
                fit: BoxFit.cover,
                placeholderSeed: 'iphone14',
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 20),

            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: $category • Type: ${type.toUpperCase()}',
                    style: TextStyle(
                      color: type == 'lost'
                          ? AppColors.error
                          : AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Location: $location',
                    style: const TextStyle(color: AppColors.outline),
                  ),
                  if (rewardAmount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Reward Offered: ৳ ${rewardAmount.round()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),

            PrimaryButton(
              text: 'Publish Report to Feed',
              icon: Icons.cloud_upload_rounded,
              isLoading: _isPublishing,
              onPressed: _handlePublish,
            ),
          ],
        ),
      ),
    );
  }
}
