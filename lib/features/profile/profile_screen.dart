import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/providers/providers.dart';

import '../../core/models/recovery_models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider).value;
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header Card
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundImage: NetworkImage(
                          user?.photoUrl.isNotEmpty == true
                              ? user!.photoUrl
                              : 'https://i.pravatar.cc/150?img=60',
                        ),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary,
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.displayName ?? 'Tanvir Ahmed',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'tanvir@example.com',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // NID Verified Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'NID Verified Member',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Stats Grid (Recoveries, Returns, Rating, Trust Score, Reviews)
            StreamBuilder<List<RatingModel>>(
              stream: ref
                  .watch(firestoreServiceProvider)
                  .streamRatingsForUser(user?.uid ?? 'guest'),
              builder: (context, ratingsSnap) {
                final ratings = ratingsSnap.data ?? [];
                final ratingCount = ratings.length;
                double calcAvg = 5.0;
                if (ratings.isNotEmpty) {
                  final sum = ratings.fold<double>(
                    0.0,
                    (prev, r) => prev + r.rating,
                  );
                  calcAvg = double.parse(
                    (sum / ratings.length).toStringAsFixed(1),
                  );
                }
                final displayAvg = ratings.isNotEmpty
                    ? calcAvg
                    : (user?.averageRating ?? 5.0);
                final displayCount = ratings.isNotEmpty
                    ? ratingCount
                    : (user?.totalReviews ?? 0);

                return StreamBuilder(
                  stream: ref
                      .watch(firestoreServiceProvider)
                      .streamWallet(user?.uid ?? 'guest'),
                  builder: (context, walletSnap) {
                    final wallet = walletSnap.data;
                    final totalEarned = wallet?.totalEarned.toInt() ?? 0;

                    return StreamBuilder(
                      stream: ref
                          .watch(firestoreServiceProvider)
                          .streamUserHistory(user?.uid ?? 'guest'),
                      builder: (context, historySnap) {
                        final historyList = historySnap.data ?? [];
                        final recCount =
                            user?.completedRecoveries ?? historyList.length;
                        final retCount = user?.completedReturns ?? 0;
                        final trustScore = user?.trustScore ?? 100;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GlassContainer(
                                    borderRadius: 16,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Text(
                                          '$recCount',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Recoveries',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GlassContainer(
                                    borderRadius: 16,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Text(
                                          '$retCount',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Returns',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GlassContainer(
                                    borderRadius: 16,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Text(
                                          '৳ $totalEarned',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Earned',
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
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GlassContainer(
                                    borderRadius: 16,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              '$displayAvg',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$displayCount Reviews',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GlassContainer(
                                    borderRadius: 16,
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Text(
                                          '$trustScore%',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Trust Score',
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
                            const SizedBox(height: 16),

                            // Ratings & Reviews Breakdown Card
                            GlassContainer(
                              borderRadius: 20,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'User Rating: $displayAvg / 5.0',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '$displayCount reviews',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: List.generate(5, (index) {
                                      final starVal = index + 1;
                                      return Icon(
                                        starVal <= displayAvg.floor()
                                            ? Icons.star_rounded
                                            : (starVal - displayAvg <= 0.5
                                                  ? Icons.star_half_rounded
                                                  : Icons.star_outline_rounded),
                                        color: Colors.amber,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                  if (ratings.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Recent Ratings & Reviews:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: ratings.length > 3
                                          ? 3
                                          : ratings.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 8),
                                      itemBuilder: (context, idx) {
                                        final r = ratings[idx];
                                        return Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.05,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star_rounded,
                                                        color: Colors.amber,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${r.rating}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppColors.outline,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (r.review.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  '"${r.review}"',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            // Options List
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/edit-profile'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.history_edu_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text('Recovery History Archive'),
                    subtitle: const Text('View completed & returned items'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/recovery-history'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.green,
                    ),
                    title: const Text('Earnings & Wallet'),
                    subtitle: const Text(
                      'Reward earnings & transaction history',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/wallet'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.emoji_events_outlined,
                      color: Colors.amber,
                    ),
                    title: const Text('Community Leaderboard'),
                    subtitle: const Text('Top recovery heroes & rankings'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/leaderboard'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.post_add_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text('My Reported Posts'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/my-posts'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.favorite_outline_rounded,
                      color: AppColors.error,
                    ),
                    title: const Text('Favorites'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/favorites'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('NID Verification'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/nid-verification'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.local_police_outlined,
                      color: Colors.indigo,
                    ),
                    title: const Text('Police GD Integration'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/police-gd'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) context.go('/welcome');
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
