import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/providers/providers.dart';

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
                        child: const Icon(Icons.check, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.displayName ?? 'Tanvir Ahmed',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'tanvir@example.com',
                    style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),

                  // NID Verified Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'NID Verified Member',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: const [
                        Text('14', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        SizedBox(height: 2),
                        Text('Items Found', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassContainer(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: const [
                        Text('1,250', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        SizedBox(height: 2),
                        Text('Points', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Options List
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/edit-profile'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.post_add_rounded, color: AppColors.primary),
                    title: const Text('My Reported Posts'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/my-posts'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline_rounded, color: AppColors.error),
                    title: const Text('Favorites'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/favorites'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.amber),
                    title: const Text('Rewards Wallet'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/rewards'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.leaderboard_outlined, color: AppColors.secondary),
                    title: const Text('Leaderboard'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/leaderboard'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
                    title: const Text('NID Verification'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/nid-verification'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.local_police_outlined, color: Colors.indigo),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) context.go('/welcome');
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
