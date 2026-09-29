import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/providers/providers.dart';
import '../../core/models/post_model.dart';
import '../../core/utils/app_localizations.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;
    final favoriteIds = ref.watch(favoritesNotifierProvider);
    final postsAsync = ref.watch(rawAllPostsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'সংরক্ষিত পছন্দের তালিকা' : 'Saved Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: postsAsync.when(
        data: (allPosts) {
          final favPosts = allPosts
              .where((post) => favoriteIds.contains(post.id))
              .toList();

          if (favPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline_rounded,
                    size: 72,
                    color: AppColors.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isBn
                        ? 'কোনো সংরক্ষিত পছন্দের আইটেম নেই'
                        : 'No Saved Favorites Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn
                        ? 'আপনার পছন্দের বস্তুগুলি সংরক্ষণ করতে হার্ট আইকনে ট্যাপ করুন।'
                        : 'Tap the heart icon on any post to save it to favorites.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favPosts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = favPosts[index];
              final imageUrl = post.images.isNotEmpty
                  ? post.images.first
                  : 'https://picsum.photos/seed/${post.id}/100/100';

              return GlassContainer(
                onTap: () => context.push('/item-details/${post.id}'),
                borderRadius: 18,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: AppColors.primaryContainer,
                          child: const Icon(Icons.image_not_supported_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: post.type == 'lost'
                                      ? AppColors.error.withValues(alpha: 0.15)
                                      : AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  post.type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: post.type == 'lost'
                                        ? AppColors.error
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  post.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: AppColors.outline,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  post.location.isNotEmpty
                                      ? post.location
                                      : 'Dhaka, Bangladesh',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        ref
                            .read(favoritesNotifierProvider.notifier)
                            .toggleFavorite(post.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isBn
                                  ? 'পছন্দের তালিকা থেকে সরানো হয়েছে!'
                                  : 'Removed from Favorites!',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      tooltip: loc.t('favorites'),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            isBn ? 'ডেটা লোড করতে ব্যর্থ হয়েছে' : 'Failed to load favorites',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
