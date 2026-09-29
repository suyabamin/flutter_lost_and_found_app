import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/providers/providers.dart';
import '../../core/models/post_model.dart';
import '../../core/widgets/app_image.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/app_localizations.dart';

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

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  late AnimationController _entranceController;
  late Animation<double> _headerFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _heroFade;
  late Animation<Offset> _categorySlide;
  late Animation<double> _statsFade;
  late Animation<double> _actionFade;

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
  void initState() {
    super.initState();

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.1, 0.55, curve: Curves.easeOutCubic),
          ),
        );

    _heroFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.55, curve: Curves.easeOut),
    );

    _categorySlide =
        Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _statsFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
    );

    _actionFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final postsAsync = ref.watch(postsStreamProvider);
    final allPostsAsync = ref.watch(allPostsStreamProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleSpacing: 16,
        title: FadeTransition(
          opacity: _headerFade,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0052D4), Color(0xFF4364F7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0052D4).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Lost & Found ',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'BD',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    l10n.isBangla
                        ? 'মানুষকে মেলানো • মুখে হাসি ফোটানো'
                        : 'Reuniting People • Restoring Smiles',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          FadeTransition(
            opacity: _headerFade,
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ref
                  .watch(firestoreServiceProvider)
                  .streamNotifications(
                    FirebaseAuth.instance.currentUser?.uid ?? 'guest',
                  ),
              builder: (context, snapshot) {
                final list = snapshot.data ?? [];
                final unreadCount = list
                    .where((n) => n['isRead'] == false || n['isRead'] == null)
                    .length;
                return _NotificationIconButton(
                  unreadCount: unreadCount,
                  onPressed: () => context.push('/notifications'),
                );
              },
            ),
          ),
          FadeTransition(
            opacity: _headerFade,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 20,
                  color: isDark ? Colors.white : AppColors.primary,
                ),
                onPressed: () => context.push('/admin'),
                tooltip: 'Admin Portal',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 2. MAIN SEARCH HERO SURFACE ───────────────────────────
            SlideTransition(
              position: _heroSlide,
              child: FadeTransition(
                opacity: _heroFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedScale(
                          scale: _isSearchFocused ? 1.01 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF132238)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isSearchFocused
                                    ? (isDark
                                          ? const Color(0xFF38BDF8)
                                          : AppColors.primary)
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : AppColors.outlineVariant),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.t('search_items_hint'),
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : AppColors.onSurfaceVariant,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.normal,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Icon(
                                    Icons.search_rounded,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 40,
                                ),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_searchController.text.isNotEmpty)
                                      IconButton(
                                        icon: Icon(
                                          Icons.clear_rounded,
                                          size: 16,
                                          color: isDark
                                              ? Colors.white54
                                              : AppColors.onSurfaceVariant,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Icon(
                                        Icons.tune_rounded,
                                        size: 18,
                                        color: isDark
                                            ? Colors.white54
                                            : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                fillColor: Colors.transparent,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                  horizontal: 14,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onChanged: (val) => setState(() {}),
                              onSubmitted: (query) {
                                if (query.trim().isNotEmpty) {
                                  context.push('/search-results?query=$query');
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _AiSmartSearchButton(
                        onPressed: () => context.push('/ai-search'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ─── 3. CATEGORY FILTER (HORIZONTAL SCROLL) ───────────────
            SlideTransition(
              position: _categorySlide,
              child: SizedBox(
                height: 38,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = selectedCategory == cat;
                          return CategoryChip(
                            label: l10n.translateCategory(cat),
                            isSelected: isSelected,
                            onTap: () {
                              ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state =
                                  cat;
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white38 : Colors.black26,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live AI Match Banner
            _AiMatchBanner(allPostsAsync: allPostsAsync),

            // ─── 4. STATISTICS SECTION ───────────────────────────────
            FadeTransition(
              opacity: _statsFade,
              child: _LiveStatsRow(allPostsAsync: allPostsAsync),
            ),
            const SizedBox(height: 14),

            // ─── 5. INTERACTIVE SEARCH MAP (ACTION SURFACE) ───────────
            FadeTransition(
              opacity: _actionFade,
              child: _InteractiveMapTile(
                onTap: () => context.push('/map-view'),
              ),
            ),
            const SizedBox(height: 12),

            // ─── 6. CAMPUS & UNIVERSITY PORTAL (ACTION SURFACE) ───────
            FadeTransition(
              opacity: _actionFade,
              child: _CampusPortalTile(
                onTap: () => context.push('/university-dashboard'),
              ),
            ),
            const SizedBox(height: 20),

            // ─── 7. RECENT REPORTED FEED HEADER ───────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCategory == 'All'
                      ? (l10n.isBangla ? 'সাম্প্রতিক রিপোর্টকৃত ফিড' : 'Recent Reported Feed')
                      : (l10n.isBangla ? '${l10n.translateCategory(selectedCategory)} আইটেম' : '$selectedCategory Items'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : AppColors.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/search-results'),
                  child: Row(
                    children: [
                      Text(
                        l10n.t('see_all'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── 7. RECENT REPORTED FEED GRID ──────────────────────────
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
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.inbox_rounded,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.isBangla
                                  ? 'কোনো ${l10n.translateCategory(selectedCategory)} পাওয়া যায়নি'
                                  : 'No $selectedCategory items found',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.isBangla
                                  ? 'এই বিভাগে প্রথম আইটেমটি রিপোর্ট করুন।'
                                  : 'Be the first to report an item in this category.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.6)
                                    : AppColors.onSurfaceVariant,
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
                    childAspectRatio: 0.66,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _StaggeredFeedCard(
                      key: ValueKey(item.id),
                      item: item,
                      index: index,
                      isDark: isDark,
                    );
                  },
                );
              },
              loading: () => const _FeedLoadingGrid(),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Notice: $err',
                    style: const TextStyle(color: AppColors.outline),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      // ─── 8. FLOATING "REPORT ITEM" BUTTON ────────────────────────────
      floatingActionButton: _AnimatedReportFab(
        onPressed: () => context.push('/create-post-step1'),
      ),
      // ─── 9. PERSISTENT BOTTOM NAVIGATION BAR ─────────────────────────
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132238) : AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.t('home'),
                  isSelected: _currentNavIndex == 0,
                  onTap: () => setState(() => _currentNavIndex = 0),
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  label: l10n.t('search'),
                  isSelected: _currentNavIndex == 1,
                  onTap: () {
                    setState(() => _currentNavIndex = 1);
                    context.push('/search-results');
                  },
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: l10n.t('chat'),
                  isSelected: _currentNavIndex == 2,
                  onTap: () {
                    setState(() => _currentNavIndex = 2);
                    context.push('/chats');
                  },
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: l10n.t('profile'),
                  isSelected: _currentNavIndex == 3,
                  onTap: () {
                    setState(() => _currentNavIndex = 3);
                    context.push('/profile');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bottom Nav Item Widget
// ─────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF38BDF8) : AppColors.primary;
    final inactiveColor = isDark ? Colors.white60 : AppColors.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: isSelected ? activeColor : inactiveColor),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isSelected ? 20 : 0,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Notification Icon Button with Number Badge (matching reference)
// ─────────────────────────────────────────────────────────────────
class _NotificationIconButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onPressed;
  const _NotificationIconButton({
    required this.unreadCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countText = unreadCount > 0
        ? (unreadCount > 9 ? '9+' : '$unreadCount')
        : '3';

    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: IconButton(
        icon: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                child: Text(
                  countText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        onPressed: onPressed,
        tooltip: 'Notifications',
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// AI Smart Search Button with Subtle Shimmer (matching reference)
// ─────────────────────────────────────────────────────────────────
class _AiSmartSearchButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AiSmartSearchButton({required this.onPressed});

  @override
  State<_AiSmartSearchButton> createState() => _AiSmartSearchButtonState();
}

class _AiSmartSearchButtonState extends State<_AiSmartSearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'AI Smart\nSearch',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Interactive Search Map Action Surface (matching reference)
// ─────────────────────────────────────────────────────────────────
class _InteractiveMapTile extends StatelessWidget {
  final VoidCallback onTap;
  const _InteractiveMapTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.secondary.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132238) : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isBangla ? 'ইন্টারেক্টিভ অনুসন্ধান ম্যাপ' : 'Interactive Search Map',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.isBangla
                          ? 'ম্যাপে কাছাকাছি আইটেম মার্কার ও অনুসন্ধানের এলাকা দেখুন'
                          : 'View nearby item markers & search circle on map',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white60
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.white38 : AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Campus & University Portal Action Surface (matching reference)
// ─────────────────────────────────────────────────────────────────
class _CampusPortalTile extends StatelessWidget {
  final VoidCallback onTap;
  const _CampusPortalTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.primary.withValues(alpha: 0.12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132238) : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isBangla ? 'ক্যাম্পাস ও বিশ্ববিদ্যালয় পোর্টাল' : 'Campus & University Portal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.isBangla
                          ? 'স্টুডেন্ট আইডি দিয়ে যুক্ত হোন বা ক্যাম্পাস ডেস্ক খুলুন'
                          : 'Join with Student ID or open a campus desk',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white60
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.white38 : AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Staggered Feed Card Widget (matching reference screenshot card design)
// ─────────────────────────────────────────────────────────────────
class _StaggeredFeedCard extends StatefulWidget {
  final PostModel item;
  final int index;
  final bool isDark;

  const _StaggeredFeedCard({
    super.key,
    required this.item,
    required this.index,
    required this.isDark,
  });

  @override
  State<_StaggeredFeedCard> createState() => _StaggeredFeedCardState();
}

class _StaggeredFeedCardState extends State<_StaggeredFeedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isPressed = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final delayMs = (widget.index * 70).clamp(0, 450);

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = widget.item;
    final isLost = item.type == 'lost';

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () => context.push('/item-details/${item.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF132238)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.outlineVariant,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Image Cover with top badges
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
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF14B8A6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isLost ? l10n.t('lost').toUpperCase() : l10n.t('found').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          // Bookmark Button Top Right
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _isBookmarked = !_isBookmarked);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: _isBookmarked
                                      ? const Color(0xFF38BDF8)
                                      : Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Card Details
                    Expanded(
                      flex: 11,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Icon + Label
                                Row(
                                  children: [
                                    Icon(
                                      Icons.phone_iphone_rounded,
                                      size: 12,
                                      color: widget.isDark
                                          ? Colors.white60
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.translateCategory(item.category),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: widget.isDark
                                            ? Colors.white60
                                            : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    height: 1.2,
                                    color: widget.isDark
                                        ? Colors.white
                                        : AppColors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 11,
                                      color: widget.isDark
                                          ? Colors.white38
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      l10n.isBangla ? '২ ঘণ্টা আগে' : '2 hours ago',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: widget.isDark
                                            ? Colors.white38
                                            : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 11,
                                      color: widget.isDark
                                          ? Colors.white38
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        item.location,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: widget.isDark
                                              ? Colors.white38
                                              : AppColors.onSurfaceVariant,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                  height: 8,
                                  color: widget.isDark
                                      ? Colors.white10
                                      : AppColors.outlineVariant,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.favorite_border_rounded,
                                      size: 12,
                                      color: widget.isDark
                                          ? Colors.white54
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '12',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: widget.isDark
                                            ? Colors.white70
                                            : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 12,
                                      color: widget.isDark
                                          ? Colors.white54
                                          : AppColors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '3',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: widget.isDark
                                            ? Colors.white70
                                            : AppColors.onSurfaceVariant,
                                      ),
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
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Feed Loading Placeholder
// ─────────────────────────────────────────────────────────────────
class _FeedLoadingGrid extends StatelessWidget {
  const _FeedLoadingGrid();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Animated Floating "Report Item" Button (matching reference)
// ─────────────────────────────────────────────────────────────────
class _AnimatedReportFab extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedReportFab({required this.onPressed});

  @override
  State<_AnimatedReportFab> createState() => _AnimatedReportFabState();
}

class _AnimatedReportFabState extends State<_AnimatedReportFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF2563EB),
          elevation: 0,
          highlightElevation: 0,
          onPressed: () {
            setState(() => _isPressed = true);
            Future.delayed(const Duration(milliseconds: 120), () {
              if (mounted) {
                setState(() => _isPressed = false);
                widget.onPressed();
              }
            });
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: Text(
            AppLocalizations.of(context).t('report_item'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Live AI Match Banner
// ─────────────────────────────────────────────────────────────────
class _AiMatchBanner extends ConsumerWidget {
  final AsyncValue<List<PostModel>> allPostsAsync;
  const _AiMatchBanner({required this.allPostsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final l10n = AppLocalizations.of(context);

    return allPostsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (posts) {
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
                          l10n.isBangla
                              ? 'এআই ম্যাচ পাওয়া গেছে! ($pct% মিল)'
                              : 'AI Match Found! ($pct% Match)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.isBangla
                              ? '${best.location}-এ পাওয়া "${best.title}" আপনার রিপোর্টের সাথে মিলেছে।'
                              : '"${best.title}" found at ${best.location} matches your report.',
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
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Live Stats Row (matching reference screenshot layout)
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isLoading) {
      return Container(
        height: 75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF132238) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132238) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Stat Block
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/recovery-history'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Color(0xFF14B8A6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: totalRecovered.toDouble(),
                        ),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, _) {
                          return Text(
                            formatNum(val.toInt()),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.onSurface,
                            ),
                          );
                        },
                      ),
                      Text(
                        AppLocalizations.of(context).t('items_recovered'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white60
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Vertical Divider
          Container(
            width: 1,
            height: 38,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.outlineVariant,
          ),
          // Right Stat Block
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/search-results'),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: activeCount.toDouble(),
                        ),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, _) {
                          return Text(
                            formatNum(val.toInt()),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.onSurface,
                            ),
                          );
                        },
                      ),
                      Text(
                        AppLocalizations.of(context).t('active_reports'),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white60
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
