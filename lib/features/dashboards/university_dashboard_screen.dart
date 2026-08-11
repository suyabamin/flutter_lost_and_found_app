import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/app_image.dart';
import '../../core/providers/providers.dart';
import '../../core/models/campus_models.dart';
import '../../core/models/post_model.dart';
import '../../core/services/firestore_service.dart';

final _defaultCampus = CampusModel(
  id: 'du_tsc_01',
  code: 'DU-TSC-01',
  name: 'Dhaka University Desk',
  institutionName: 'University of Dhaka',
  description: 'Central management portal for the Proctor Office & TSC.',
  location: 'Dhaka, Bangladesh',
  address: 'TSC & Curzon Hall, DU',
  creatorId: 'system_admin',
  creatorName: 'DU Proctor Office',
);

class UniversityDashboardScreen extends ConsumerStatefulWidget {
  const UniversityDashboardScreen({super.key});

  @override
  ConsumerState<UniversityDashboardScreen> createState() =>
      _UniversityDashboardScreenState();
}

class _UniversityDashboardScreenState
    extends ConsumerState<UniversityDashboardScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Electronics',
    'Documents',
    'Keys',
    'Wallets',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider).value;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final uid = firebaseUser?.uid ?? 'guest';

    // Watch selected campus or default
    final activeCampus = ref.watch(selectedCampusProvider) ?? _defaultCampus;

    // Streams
    final campusPostsAsync = ref.watch(
      campusPostsStreamProvider(activeCampus.id),
    );
    final campusMembersAsync = ref.watch(
      campusMembersStreamProvider(activeCampus.id),
    );
    final userMembershipsAsync = ref.watch(userCampusMembershipsProvider);
    final allCampusesAsync = ref.watch(allCampusesStreamProvider);

    // Current student's membership for active campus
    final myMembership = userMembershipsAsync.value
        ?.where((m) => m.campusId == activeCampus.id)
        .firstOrNull;

    // All campuses the user has already joined (for the chip row)
    final joinedCampusIds =
        userMembershipsAsync.value?.map((m) => m.campusId).toSet() ?? {};
    final allCampusesList = allCampusesAsync.value ?? [];
    final myCampuses = [
      _defaultCampus,
      ...allCampusesList.where(
        (c) => c.id != _defaultCampus.id && joinedCampusIds.contains(c.id),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campus Lost & Found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              activeCampus.name,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Switch or Join Campus',
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => _showCampusSwitchModal(context, uid),
          ),
          IconButton(
            tooltip: 'Create New Campus',
            icon: const Icon(Icons.add_business_rounded),
            onPressed: () =>
                _showCreateCampusModal(context, uid, currentUser?.displayName),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── MY CAMPUSES CHIP ROW ──────────────────────────────────
            if (myCampuses.isNotEmpty) ...[
              Row(
                children: [
                  const Text(
                    'My Campuses',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showCampusSwitchModal(context, uid),
                    child: const Text(
                      'Manage →',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: myCampuses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final campus = myCampuses[index];
                    final isActive = campus.id == activeCampus.id;
                    return GestureDetector(
                      onTap: () {
                        ref.read(selectedCampusProvider.notifier).state =
                            campus;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : (isDark ? AppColors.darkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.outline.withValues(alpha: 0.3),
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.school_rounded,
                              size: 14,
                              color: isActive
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              campus.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Campus Header & Identity Bento Card
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    activeCampus.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    activeCampus.code,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeCampus.institutionName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: AppColors.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            currentUser?.displayName ?? 'Student User',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (myMembership != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.badge_outlined,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ID: ${myMembership.studentId}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () =>
                              _showJoinCampusModal(context, activeCampus, uid),
                          icon: const Icon(Icons.login_rounded, size: 14),
                          label: const Text(
                            'Join with Student ID',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bento Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(height: 8),
                        campusPostsAsync.when(
                          data: (posts) => Text(
                            '${posts.length}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => const Text(
                            '...',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          error: (_, __) => const Text(
                            '0',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(
                          'Desk Items',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.people_outline_rounded,
                          color: AppColors.secondary,
                          size: 22,
                        ),
                        const SizedBox(height: 8),
                        campusMembersAsync.when(
                          data: (members) => Text(
                            '${members.length}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          loading: () => const Text(
                            '...',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          error: (_, __) => const Text(
                            '1',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(
                          'Campus Members',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Colors.green,
                          size: 22,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeCampus.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Campus Inventory Feed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showCreateCampusReportModal(
                    context,
                    activeCampus,
                    uid,
                    currentUser?.displayName,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Report Item',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Categories Filter
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: isDark
                        ? AppColors.darkSurface
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Campus Posts List
            campusPostsAsync.when(
              data: (posts) {
                final filtered = _selectedCategory == 'All'
                    ? posts
                    : posts
                          .where(
                            (p) =>
                                p.category.toLowerCase() ==
                                _selectedCategory.toLowerCase(),
                          )
                          .toList();

                if (filtered.isEmpty) {
                  return GlassContainer(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              size: 48,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No $_selectedCategory reports for ${activeCampus.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Be the first student or desk officer to report a found item.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.outline,
                              ),
                              textAlign: TextAlign.center,
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
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isLost = item.type == 'lost';

                    return GestureDetector(
                      onTap: () => context.push('/item-details/${item.id}'),
                      child: GlassContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            AppImage(
                              url: item.images.isNotEmpty
                                  ? item.images.first
                                  : '',
                              bytes: FirestoreService.getLocalImageBytes(
                                item.id,
                              )?.firstOrNull,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            const SizedBox(width: 12),
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
                                          color: isLost
                                              ? AppColors.error
                                              : AppColors.secondary,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                      const SizedBox(width: 6),
                                      Text(
                                        item.category,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.outline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.location} • By ${item.userName}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.outline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.outline,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) =>
                  Center(child: Text('Campus stream error: $err')),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MODAL: CREATE CAMPUS
  // ─────────────────────────────────────────────────────────────
  void _showCreateCampusModal(
    BuildContext context,
    String uid,
    String? userName,
  ) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final instCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.add_business_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Open New Campus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Campus Name *',
                  hintText: 'e.g. Dhaka University Desk',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Unique Campus Code *',
                  hintText: 'e.g. DU-TSC-01',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: instCtrl,
                decoration: const InputDecoration(
                  labelText: 'Institution Name *',
                  hintText: 'e.g. University of Dhaka',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Address / Location',
                  hintText: 'e.g. TSC & Curzon Hall',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Proctor office central desk details',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty ||
                  codeCtrl.text.trim().isEmpty ||
                  instCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please fill all required fields (Name, Code, Institution).',
                    ),
                  ),
                );
                return;
              }

              final cleanCode = codeCtrl.text.toUpperCase().trim();
              final firestore = ref.read(firestoreServiceProvider);

              // Check if code already exists
              final existing = await firestore.getCampusByCode(cleanCode);
              if (existing != null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Campus code "$cleanCode" is already registered! Use a unique code.',
                      ),
                    ),
                  );
                }
                return;
              }

              final campus = CampusModel(
                id: 'cmp_${DateTime.now().millisecondsSinceEpoch}',
                code: cleanCode,
                name: nameCtrl.text.trim(),
                institutionName: instCtrl.text.trim(),
                description: descCtrl.text.trim(),
                address: addrCtrl.text.trim(),
                creatorId: uid,
                creatorName: userName ?? 'Campus Author',
              );

              await firestore.createCampus(campus);

              // AUTO-JOIN: creator is automatically a campus_admin member
              await firestore.joinCampus(
                campusId: campus.id,
                uid: uid,
                studentId: 'ADMIN',
                role: 'campus_admin',
              );

              ref.read(selectedCampusProvider.notifier).state = campus;

              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Campus "${campus.name}" created! You are now its admin.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Create & Open'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MODAL: JOIN CAMPUS WITH STUDENT ID
  // ─────────────────────────────────────────────────────────────
  void _showJoinCampusModal(
    BuildContext context,
    CampusModel campus,
    String uid, {
    String? prefilledCode,
  }) {
    final codeCtrl = TextEditingController(text: prefilledCode ?? campus.code);
    final studentIdCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.badge_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Student ID Campus Login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Campus Code *',
                hintText: 'e.g. DU-TSC-01',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: studentIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Student ID Number *',
                hintText: 'e.g. 2021-120-456',
                helperText: 'Your Student ID is sensitive and kept secure.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (studentIdCtrl.text.trim().isEmpty ||
                  codeCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please enter both Campus Code and Student ID.',
                    ),
                  ),
                );
                return;
              }

              final firestore = ref.read(firestoreServiceProvider);
              final targetCampus = await firestore.getCampusByCode(
                codeCtrl.text.trim(),
              );

              if (targetCampus == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Campus code "${codeCtrl.text.trim()}" not found.',
                      ),
                    ),
                  );
                }
                return;
              }

              await firestore.joinCampus(
                campusId: targetCampus.id,
                uid: uid,
                studentId: studentIdCtrl.text.trim(),
              );

              ref.read(selectedCampusProvider.notifier).state = targetCampus;

              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully joined ${targetCampus.name}!'),
                  ),
                );
              }
            },
            child: const Text('Join Campus'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MODAL: CAMPUS SWITCHER (tabbed: My Campuses | Discover)
  // ─────────────────────────────────────────────────────────────
  void _showCampusSwitchModal(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CampusSwitchSheet(
        uid: uid,
        defaultCampus: _defaultCampus,
        onJoin: (campus) => _showJoinCampusModal(
          context,
          campus,
          uid,
          prefilledCode: campus.code,
        ),
        onJoinByCode: () => _showJoinCampusModal(
          context,
          _defaultCampus,
          uid,
          prefilledCode: '',
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MODAL: CREATE CAMPUS REPORT
  // ─────────────────────────────────────────────────────────────
  void _showCreateCampusReportModal(
    BuildContext context,
    CampusModel campus,
    String uid,
    String? userName,
  ) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController(
      text: campus.address.isNotEmpty ? campus.address : campus.location,
    );
    String type = 'found';
    String category = 'Electronics';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Report Item for ${campus.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Found Item'),
                      selected: type == 'found',
                      onSelected: (val) => setDialogState(() => type = 'found'),
                      selectedColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: type == 'found'
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Lost Item'),
                      selected: type == 'lost',
                      onSelected: (val) => setDialogState(() => type = 'lost'),
                      selectedColor: AppColors.error,
                      labelStyle: TextStyle(
                        color: type == 'lost'
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Item Title *',
                    hintText: 'e.g. Student ID Card / Wallet',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .where((c) => c != 'All')
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location on Campus',
                    hintText: 'e.g. TSC Cafe / Hall Library',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description / Details',
                    hintText: 'Specific markings or details',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an item title.'),
                    ),
                  );
                  return;
                }

                final post = PostModel(
                  id: 'post_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  category: category,
                  type: type,
                  location: locationCtrl.text.trim(),
                  date: DateTime.now().toString().split(' ').first,
                  images: const [],
                  userId: uid,
                  userName: userName ?? 'Campus Student',
                  campusId: campus.id,
                );

                await ref.read(firestoreServiceProvider).createPost(post);

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Campus report "${post.title}" published!'),
                    ),
                  );
                }
              },
              child: const Text('Publish Report'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CAMPUS SWITCH SHEET — tabbed (My Campuses | Discover)
// ─────────────────────────────────────────────────────────────
class _CampusSwitchSheet extends ConsumerStatefulWidget {
  final String uid;
  final CampusModel defaultCampus;
  final void Function(CampusModel campus) onJoin;
  final VoidCallback onJoinByCode;

  const _CampusSwitchSheet({
    required this.uid,
    required this.defaultCampus,
    required this.onJoin,
    required this.onJoinByCode,
  });

  @override
  ConsumerState<_CampusSwitchSheet> createState() => _CampusSwitchSheetState();
}

class _CampusSwitchSheetState extends ConsumerState<_CampusSwitchSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCampusesAsync = ref.watch(allCampusesStreamProvider);
    final userMembershipsAsync = ref.watch(userCampusMembershipsProvider);

    final joinedIds =
        userMembershipsAsync.value?.map((m) => m.campusId).toSet() ?? {};

    final allList = allCampusesAsync.value ?? [];

    // My Campuses = default + campuses the user explicitly joined
    final myCampusesList = [
      widget.defaultCampus,
      ...allList.where(
        (c) => c.id != widget.defaultCampus.id && joinedIds.contains(c.id),
      ),
    ];

    // Discover = campuses NOT yet joined (exclude default)
    final discoverList = allList
        .where(
          (c) => c.id != widget.defaultCampus.id && !joinedIds.contains(c.id),
        )
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Campus Manager',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onJoinByCode();
                        },
                        icon: const Icon(Icons.vpn_key_rounded, size: 14),
                        label: const Text(
                          'Join by Code',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.outline,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              tabs: [
                Tab(text: 'My Campuses (${myCampusesList.length})'),
                Tab(text: 'Discover (${discoverList.length})'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── MY CAMPUSES TAB ───────────────────────────
                  _buildMyCampusesTab(myCampusesList, scrollController),

                  // ── DISCOVER TAB ──────────────────────────────
                  _buildDiscoverTab(
                    discoverList,
                    allCampusesAsync,
                    scrollController,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyCampusesTab(
    List<CampusModel> myCampusesList,
    ScrollController scrollController,
  ) {
    if (myCampusesList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'You have not joined any campuses yet.\nGo to Discover to find and join one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.outline),
          ),
        ),
      );
    }

    final activeCampus = ref.watch(selectedCampusProvider);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemCount: myCampusesList.length,
      itemBuilder: (context, index) {
        final campus = myCampusesList[index];
        final isActive =
            (activeCampus?.id ?? widget.defaultCampus.id) == campus.id;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isActive
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.15),
            child: Icon(
              Icons.school,
              color: isActive ? Colors.white : AppColors.primary,
              size: 18,
            ),
          ),
          title: Text(
            campus.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.primary : null,
            ),
          ),
          subtitle: Text(
            '${campus.institutionName} • ${campus.code}',
            style: const TextStyle(fontSize: 11),
          ),
          trailing: isActive
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const Icon(Icons.chevron_right, color: AppColors.outline),
          onTap: () {
            ref.read(selectedCampusProvider.notifier).state = campus;
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildDiscoverTab(
    List<CampusModel> discoverList,
    AsyncValue<List<CampusModel>> allCampusesAsync,
    ScrollController scrollController,
  ) {
    return allCampusesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('Could not load campuses. Check connection.'),
      ),
      data: (_) {
        if (discoverList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.celebration_rounded,
                    size: 48,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'You have joined all available campuses!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onJoinByCode();
                    },
                    icon: const Icon(Icons.vpn_key_rounded, size: 14),
                    label: const Text('Join a campus by its code'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          itemCount: discoverList.length,
          itemBuilder: (context, index) {
            final campus = discoverList[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.school_outlined,
                  color: AppColors.secondary,
                  size: 18,
                ),
              ),
              title: Text(
                campus.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${campus.institutionName} • ${campus.code}',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onJoin(campus);
                },
                child: const Text(
                  'Join',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
