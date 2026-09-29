import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/app_image.dart';
import '../../core/models/post_model.dart';
import '../../core/providers/providers.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/post_delete_helper.dart';

class MyPostsScreen extends ConsumerWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reported Posts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please sign in to view your posts'))
          : StreamBuilder<List<PostModel>>(
              stream: firestoreService.streamUserPosts(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userPosts = snapshot.data ?? [];
                if (userPosts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.post_add_rounded,
                            size: 72,
                            color: AppColors.outline.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Posts Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Your lost and found posts will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/create-post-step1'),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create Post'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: userPosts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = userPosts[index];
                    return InkWell(
                      onTap: () => context.push('/item-details/${item.id}'),
                      borderRadius: BorderRadius.circular(18),
                      child: GlassContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            AppImage(
                              url: item.images.isNotEmpty
                                  ? item.images.first
                                  : '',
                              bytes: FirestoreService.getLocalImageBytes(
                                item.id,
                              )?.firstOrNull,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholderSeed: item.id,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${item.status.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: item.status == 'completed'
                                          ? Colors.green
                                          : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.location,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                  ),
                                  tooltip: 'Edit Post',
                                  onPressed: () =>
                                      context.push('/edit-post/${item.id}'),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                  ),
                                  tooltip: 'Delete Post',
                                  onPressed: () =>
                                      PostDeleteHelper.confirmAndDeletePost(
                                        context: context,
                                        ref: ref,
                                        post: item,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
