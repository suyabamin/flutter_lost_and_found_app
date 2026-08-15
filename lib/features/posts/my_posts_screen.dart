import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/app_image.dart';
import '../../core/models/post_model.dart';
import '../../core/providers/providers.dart';
import '../../core/services/firestore_service.dart';

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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.post_add_rounded,
                          size: 72,
                          color: AppColors.outline.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'You have not reported any items yet.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.push('/create-post-step1'),
                          child: const Text('Create New Report'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: userPosts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = userPosts[index];
                    return GlassContainer(
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.location,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primary,
                            ),
                            onPressed: () =>
                                context.push('/item-details/${item.id}'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
