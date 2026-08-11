import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/models/recovery_models.dart';
import '../../core/providers/providers.dart';

class RecoveryHistoryScreen extends ConsumerStatefulWidget {
  const RecoveryHistoryScreen({super.key});

  @override
  ConsumerState<RecoveryHistoryScreen> createState() => _RecoveryHistoryScreenState();
}

class _RecoveryHistoryScreenState extends ConsumerState<RecoveryHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Recovered (Poster)', 'Returned (Finder)'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestoreService = ref.watch(firestoreServiceProvider);
    final authUser = FirebaseAuth.instance.currentUser;
    final currentUid = authUser?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery History Archive'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search recovered items, locations...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Recovered Items', 'Returned Items'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryChip(
                          label: filter,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // History Feed List
          Expanded(
            child: StreamBuilder<List<HistoryModel>>(
              stream: firestoreService.streamUserHistory(currentUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rawList = snapshot.data ?? [];
                final searchQuery = _searchController.text.trim().toLowerCase();

                final filteredList = rawList.where((item) {
                  // Filter by Search Query
                  if (searchQuery.isNotEmpty) {
                    final matchTitle = item.title.toLowerCase().contains(searchQuery);
                    final matchLoc = item.location.toLowerCase().contains(searchQuery);
                    final matchCat = item.category.toLowerCase().contains(searchQuery);
                    if (!matchTitle && !matchLoc && !matchCat) return false;
                  }

                  // Filter by Type
                  if (_selectedFilter == 'Recovered Items' && item.posterId != currentUid) {
                    return false;
                  }
                  if (_selectedFilter == 'Returned Items' && item.finderId != currentUid) {
                    return false;
                  }

                  return true;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history_toggle_off_rounded, size: 64, color: AppColors.outline),
                        SizedBox(height: 12),
                        Text('No recovery history found.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Completed recoveries will be permanently archived here.', style: TextStyle(color: AppColors.outline, fontSize: 12), textAlign: TextAlign.center),
                      ],
                    ),
                  ),);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    final isPoster = item.posterId == currentUid;

                    return GlassContainer(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.grey.shade200,
                              image: item.images.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(item.images.first), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: item.images.isEmpty
                                ? const Icon(Icons.verified_rounded, color: Colors.green)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isPoster ? AppColors.primary : AppColors.secondary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isPoster ? 'RECOVERED' : 'RETURNED',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${item.completedDate.day}/${item.completedDate.month}/${item.completedDate.year}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Location: ${item.location}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.outline),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.rewardAmount > 0) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    isPoster ? 'Reward Paid: ৳ ${item.rewardAmount.toInt()}' : 'Reward Earned: ৳ ${item.rewardAmount.toInt()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isPoster ? AppColors.error : Colors.green,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
