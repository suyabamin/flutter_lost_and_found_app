import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/live_location_card.dart';
import '../../core/widgets/radius_search_card.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/location_dashboard_provider.dart';
import '../../core/utils/location_utils.dart';

class RadiusSearchScreen extends ConsumerWidget {
  const RadiusSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsStreamProvider);
    final radiusState = ref.watch(radiusSearchProvider);
    final nearbyPostsWithDistance = ref.watch(filteredRadiusPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radius Search & Live Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded, color: AppColors.primary),
            tooltip: 'Open Interactive Map',
            onPressed: () => context.push('/map-view'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. LIVE LOCATION DASHBOARD CARD
            const LiveLocationCard(),
            const SizedBox(height: 20),

            // 2. RADIUS SEARCH FILTER CARD
            const RadiusSearchCard(),
            const SizedBox(height: 24),

            // 3. NEARBY RESULTS HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        radiusState.isEnabled
                            ? 'Nearby Items (${LocationUtils.formatDistance(radiusState.radiusKm)})'
                            : 'All Items Feed',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${nearbyPostsWithDistance.length} item(s) found in selected radius',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => context.push('/map-view'),
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text('View Map', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4. NEARBY ITEMS LIST
            postsAsync.when(
              data: (_) {
                if (nearbyPostsWithDistance.isEmpty) {
                  return GlassContainer(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.location_off_rounded,
                              size: 48,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No items found within ${LocationUtils.formatDistance(radiusState.radiusKm)} radius.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try increasing the search radius slider above or changing your search filters.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                final double nextRadius =
                                    radiusState.radiusKm < 5
                                    ? 5.0
                                    : (radiusState.radiusKm < 10
                                          ? 10.0
                                          : (radiusState.radiusKm < 25
                                                ? 25.0
                                                : 50.0));
                                ref
                                    .read(radiusSearchProvider.notifier)
                                    .setRadius(nextRadius);
                              },
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                size: 16,
                              ),
                              label: Text(
                                'Increase Radius (${LocationUtils.formatDistance(radiusState.radiusKm < 5 ? 5.0 : radiusState.radiusKm + 5)})',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: nearbyPostsWithDistance.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final itemWithDist = nearbyPostsWithDistance[index];
                    final item = itemWithDist.post;
                    final distKm = itemWithDist.distanceKm;
                    final isLost = item.type == 'lost';

                    return GestureDetector(
                      onTap: () => context.push('/item-details/${item.id}'),
                      child: GlassContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 85,
                              height: 85,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.grey.shade200,
                                image: item.images.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(item.images.first),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLost
                                            ? AppColors.error
                                            : AppColors.secondary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isLost ? 'LOST' : 'FOUND',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer
                                              .withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.near_me_rounded,
                                              color: AppColors.primary,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              LocationUtils.formatDistance(
                                                distKm,
                                              ),
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: AppColors.outline,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          item.location,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.outline,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (item.rewardAmount > 0) ...[
                                        Text(
                                          '৳${item.rewardAmount.toInt()}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ],
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
              error: (err, stack) => Center(
                child: Text(
                  'Notice: $err',
                  style: const TextStyle(color: AppColors.outline),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
