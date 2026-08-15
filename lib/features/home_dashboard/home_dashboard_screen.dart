import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/providers/providers.dart';
import '../../core/models/post_model.dart';
import '../../core/widgets/app_image.dart';
import '../../core/services/firestore_service.dart';

// All posts (unfiltered) provider — used for dashboard stats & AI match banner
final allPostsStreamProvider = StreamProvider<List<PostModel>>((ref) {
  return ref.watch(firestoreServiceProvider).streamPosts();
});

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _currentNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Electronics',
    'Wallets',
    'Pets',
    'Documents',
    'Clothing',
    'Keys',
    'Others',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final postsAsync = ref.watch(postsStreamProvider);
    // Watch all posts (unfiltered) for stats and AI match
    final allPostsAsync = ref.watch(allPostsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_searching_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Lost & Found BD',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: ref
                .watch(firestoreServiceProvider)
                .streamNotifications(
                  FirebaseAuth.instance.currentUser?.uid ?? 'guest',
                ),
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              final hasUnread = list.any(
                (n) => n['isRead'] == false || n['isRead'] == null,
              );
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded),
                    if (hasUnread && list.isNotEmpty)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () => context.push('/notifications'),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize_outlined),
            onPressed: () => context.push('/admin'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Search Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find what matters most',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search keys, pets, wallets...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (query) {
                            if (query.trim().isNotEmpty) {
                              context.push('/search-results?query=$query');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => context.push('/ai-search'),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: const Text('AI Smart Search'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = selectedCategory == cat;
                  return CategoryChip(
                    label: cat,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state = cat;
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Live AI Match Banner
            _AiMatchBanner(allPostsAsync: allPostsAsync),

            // Live Stats Grid
            _LiveStatsRow(allPostsAsync: allPostsAsync),
            const SizedBox(height: 24),

            // Map Preview Card
            GlassContainer(
              onTap: () => context.push('/map-view'),
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: AppColors.secondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Interactive Search Map',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'View nearby item markers & search circle on map',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Campus & University Portal Card
            GlassContainer(
              onTap: () => context.push('/university-dashboard'),
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campus & University Portal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Join with Student ID or open a campus desk',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Feed Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCategory == 'All'
                      ? 'Recent Reported Feed'
                      : '$selectedCategory Items',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/search-results'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Posts Feed
            postsAsync.when(
              data: (posts) {
                final filtered = selectedCategory == 'All'
                    ? posts
                    : posts.where((p) {
                        final cat = p.category.toLowerCase().trim();
                        final sel = selectedCategory.toLowerCase().trim();
                        return cat == sel ||
                            (sel.startsWith('other') &&
                                cat.startsWith('other'));
                      }).toList();

                if (filtered.isEmpty) {
                  return GlassContainer(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.inbox_rounded,
                              size: 48,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No $selectedCategory items found.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isLost = item.type == 'lost';

                    return GestureDetector(
                      onTap: () => context.push('/item-details/${item.id}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Cover Image + Badges
                            Expanded(
                              flex: 12,
                              child: Stack(
                                children: [
                                  AppImage(
                                    url: item.images.isNotEmpty
                                        ? item.images.first
                                        : '',
                                    bytes: FirestoreService.getLocalImageBytes(
                                      item.id,
                                    )?.firstOrNull,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholderSeed: item.id,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  // Status Badge (LOST / FOUND)
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLost
                                            ? AppColors.error
                                            : AppColors.secondary,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        isLost ? 'LOST' : 'FOUND',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Category Pill
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.65,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.category,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Card Info Details
                            Expanded(
                              flex: 11,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 12,
                                              color: AppColors.outline,
                                            ),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                item.location,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.outline,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (item.rewardAmount > 0)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withValues(
                                                alpha: 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Reward: ৳${item.rewardAmount.toInt()}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepOrange,
                                              ),
                                            ),
                                          ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'By ${item.userName}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.outline,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              size: 16,
                                              color: AppColors.primary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/create-post-step1'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Report Item',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (index) {
          setState(() => _currentNavIndex = index);
          if (index == 1) context.push('/search-results');
          if (index == 2) context.push('/chats');
          if (index == 3) context.push('/profile');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Live AI Match Banner
// Shows the highest-score "found" post from Firestore.
// Hidden when no match exists (similarityScore == 0).
// ─────────────────────────────────────────────────────────────────
class _AiMatchBanner extends ConsumerWidget {
  final AsyncValue<List<PostModel>> allPostsAsync;
  const _AiMatchBanner({required this.allPostsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return allPostsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (posts) {
        // Find the best "found" post that was NOT posted by the current user
        // and has a similarity score > 0
        final candidates =
            posts
                .where(
                  (p) =>
                      p.type == 'found' &&
                      p.userId != currentUid &&
                      p.similarityScore > 0,
                )
                .toList()
              ..sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

        // If no real match yet, hide banner entirely
        if (candidates.isEmpty) return const SizedBox.shrink();

        final best = candidates.first;
        final pct = (best.similarityScore * 100).toInt().clamp(0, 100);

        return Column(
          children: [
            GlassContainer(
              onTap: () => context.push('/item-details/${best.id}'),
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Match Found! ($pct% Match)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '"${best.title}" found at ${best.location} matches your report.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Live Stats Row
// Counts are derived from the live Firestore posts stream.
// ─────────────────────────────────────────────────────────────────
class _LiveStatsRow extends ConsumerWidget {
  final AsyncValue<List<PostModel>> allPostsAsync;
  const _LiveStatsRow({required this.allPostsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(allHistoryStreamProvider);
    final rawPostsAsync = ref.watch(rawAllPostsStreamProvider);

    final activeCount = allPostsAsync.maybeWhen(
      data: (posts) => posts.length,
      orElse: () => 0,
    );

    final historyList = historyAsync.value ?? [];
    final rawPosts = rawPostsAsync.value ?? [];

    final historyPostIds = historyList.map((h) => h.originalPostId).toSet();
    final rawCompleted = rawPosts
        .where(
          (p) =>
              (p.status == 'completed' || p.status == 'resolved') &&
              !historyPostIds.contains(p.id),
        )
        .length;

    final totalRecovered = historyList.length + rawCompleted;

    String formatNum(int n) {
      if (n >= 1000) {
        return '${(n / 1000).toStringAsFixed(1)}k';
      }
      return n.toString();
    }

    final isLoading = allPostsAsync.isLoading && historyAsync.isLoading;

    if (isLoading) {
      return Row(
        children: const [
          Expanded(child: _StatPlaceholder()),
          SizedBox(width: 12),
          Expanded(child: _StatPlaceholder()),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Items Recovered',
            value: formatNum(totalRecovered),
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.secondary,
            onTap: () => context.push('/recovery-history'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Active Reports',
            value: formatNum(activeCount),
            icon: Icons.schedule_rounded,
            iconColor: AppColors.primary,
            onTap: () => context.push('/search-results'),
          ),
        ),
      ],
    );
  }
}

class _StatPlaceholder extends StatelessWidget {
  const _StatPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.outlineVariant.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
