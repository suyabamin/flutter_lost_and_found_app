import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: firestoreService.streamLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return const Center(
              child: Text('No leaderboard data yet.', style: TextStyle(color: AppColors.outline)),
            );
          }

          final top1 = list.isNotEmpty ? list[0] : null;
          final top2 = list.length > 1 ? list[1] : null;
          final top3 = list.length > 2 ? list[2] : null;
          final rest = list.length > 3 ? list.sublist(3) : <UserModel>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top 3 Podium Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Rank 2 (Silver)
                    if (top2 != null)
                      Expanded(
                        child: _buildPodiumCard(
                          context,
                          user: top2,
                          rank: 2,
                          color: Colors.grey.shade400,
                          badgeIcon: Icons.workspace_premium_rounded,
                        ),
                      ),
                    const SizedBox(width: 8),

                    // Rank 1 (Gold)
                    if (top1 != null)
                      Expanded(
                        child: _buildPodiumCard(
                          context,
                          user: top1,
                          rank: 1,
                          color: Colors.amber,
                          badgeIcon: Icons.emoji_events_rounded,
                          isFirst: true,
                        ),
                      ),
                    const SizedBox(width: 8),

                    // Rank 3 (Bronze)
                    if (top3 != null)
                      Expanded(
                        child: _buildPodiumCard(
                          context,
                          user: top3,
                          rank: 3,
                          color: Colors.orange.shade700,
                          badgeIcon: Icons.military_tech_rounded,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Community Top Heroes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),

                // Remaining Ranks List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rest.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final u = rest[index];
                    final rank = index + 4;

                    return GlassContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.outlineVariant.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '#$rank',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: u.photoUrl.isNotEmpty ? NetworkImage(u.photoUrl) : null,
                            child: u.photoUrl.isEmpty ? const Icon(Icons.person_rounded) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  '${u.rewardPoints} Points • ${u.location}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          const Text('5.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodiumCard(
    BuildContext context, {
    required UserModel user,
    required int rank,
    required Color color,
    required IconData badgeIcon,
    bool isFirst = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: isFirst ? 2.5 : 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: isFirst ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: color, size: isFirst ? 30 : 24),
          const SizedBox(height: 6),
          CircleAvatar(
            radius: isFirst ? 26 : 20,
            backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
            child: user.photoUrl.isEmpty ? const Icon(Icons.person_rounded) : null,
          ),
          const SizedBox(height: 8),
          Text(
            user.displayName.split(' ').first,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: isFirst ? 14 : 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${user.rewardPoints} Pts',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
