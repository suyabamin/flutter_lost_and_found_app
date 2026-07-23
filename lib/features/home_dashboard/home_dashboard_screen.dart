import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/models/post_model.dart';
import '../../core/providers/providers.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
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
    'Others'
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
              child: const Icon(Icons.location_searching_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 8),
            const Text(
              'Lost & Found BD',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: ref.watch(firestoreServiceProvider).streamNotifications(FirebaseAuth.instance.currentUser?.uid ?? 'guest'),
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              final hasUnread = list.any((n) => n['isRead'] == false || n['isRead'] == null);

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
                            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

            // AI Match Banner
            GlassContainer(
              onTap: () => context.push('/ai-matches'),
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
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'AI Match Found! (94% Match)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'A black leather wallet found in Dhanmondi matches your report.',
                          style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Grid
            Row(
              children: const [
                Expanded(
                  child: StatCard(
                    title: 'Items Recovered',
                    value: '2,481',
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.secondary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Active Reports',
                    value: '156',
                    icon: Icons.schedule_rounded,
                    iconColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Reported Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCategory == 'All' ? 'Recent Reported Feed' : '$selectedCategory Items',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push('/search-results'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return GlassContainer(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'No items reported in "$selectedCategory" category yet.\nTap "Report Item" to post the first one!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = posts[index];
                      final isLost = item.type == 'lost';

                      return GestureDetector(
                        onTap: () => context.push('/item-details/${item.id}'),
                        child: Container(
                          width: 200,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 115,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
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
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isLost ? AppColors.error : AppColors.secondary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          isLost ? 'LOST' : 'FOUND',
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.outline),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            item.location,
                                            style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
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
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Notice: $err', style: const TextStyle(color: AppColors.outline))),
            ),
            const SizedBox(height: 24),

            // Map Preview Card
            GestureDetector(
              onTap: () => context.push('/map-view'),
              child: GlassContainer(
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
                      child: const Icon(Icons.map_rounded, color: AppColors.secondary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Live Location Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 2),
                          Text('Explore interactive pins of lost & found items near you', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.outline),
                  ],
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
        label: const Text('Report Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search_rounded), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
