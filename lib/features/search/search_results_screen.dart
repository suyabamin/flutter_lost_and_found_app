import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/providers/providers.dart';
import '../../core/models/post_model.dart';

class SearchResultsScreen extends ConsumerWidget {
  final String query;
  final String category;

  const SearchResultsScreen({
    super.key,
    this.query = '',
    this.category = 'All',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postsAsync = ref.watch(postsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(query.isNotEmpty ? 'Results for "$query"' : 'Search Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: postsAsync.when(
        data: (posts) {
          final filtered = posts.where((p) {
            final matchesQuery = query.isEmpty ||
                p.title.toLowerCase().contains(query.toLowerCase()) ||
                p.description.toLowerCase().contains(query.toLowerCase());
            final matchesCategory = category == 'All' || p.category == category;
            return matchesQuery && matchesCategory;
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 72, color: AppColors.outline.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No matching items found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Try adjusting your search terms or filters', style: TextStyle(color: AppColors.outline)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = filtered[index];
              return GestureDetector(
                onTap: () => context.push('/item-details/${item.id}'),
                child: GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.grey.shade200,
                          image: item.images.isNotEmpty
                              ? DecorationImage(image: NetworkImage(item.images.first), fit: BoxFit.cover)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.type == 'lost' ? AppColors.error : AppColors.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.type.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.outline),
                                const SizedBox(width: 4),
                                Text(item.location, style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
