import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/models/post_model.dart';
import '../../core/providers/providers.dart';

class PreviewPublishReportScreen extends ConsumerStatefulWidget {
  const PreviewPublishReportScreen({super.key});

  @override
  ConsumerState<PreviewPublishReportScreen> createState() => _PreviewPublishReportScreenState();
}

class _PreviewPublishReportScreenState extends ConsumerState<PreviewPublishReportScreen> {
  bool _isPublishing = false;

  Future<void> _handlePublish() async {
    setState(() => _isPublishing = true);

    try {
      final user = ref.read(currentUserProvider).value;
      final newPost = PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Silver iPhone 14 Pro with blue case',
        description: 'Lost somewhere around Dhanmondi Road 27. Has a small scratch on bottom left edge.',
        category: 'Electronics',
        type: 'lost',
        location: 'Dhanmondi, Dhaka',
        date: 'Today',
        images: ['https://picsum.photos/seed/iphone14/400/300'],
        userId: user?.uid ?? 'anon_user',
        userName: user?.displayName ?? 'Tanvir Ahmed',
        rewardAmount: 1000.0,
      );

      await ref.read(firestoreServiceProvider).createPost(newPost);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade300,
                image: const DecorationImage(
                  image: NetworkImage('https://picsum.photos/seed/iphone14/400/300'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Silver iPhone 14 Pro with blue case', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Category: Electronics • Type: Lost', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  SizedBox(height: 12),
                  Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Lost somewhere around Dhanmondi Road 27. Has a small scratch on bottom left edge.', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  SizedBox(height: 12),
                  Text('Location: Dhanmondi, Dhaka', style: TextStyle(color: AppColors.outline)),
                  SizedBox(height: 8),
                  Text('Reward BDT: ৳ 1,000', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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
