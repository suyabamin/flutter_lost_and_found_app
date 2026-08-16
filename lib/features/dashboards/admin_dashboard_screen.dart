import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/providers/providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Management Console'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            Row(
              children: const [
                Expanded(
                  child: StatCard(
                    title: 'Total Users',
                    value: '14,890',
                    icon: Icons.people_outline,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'AI Matches',
                    value: '1,840',
                    icon: Icons.auto_awesome,
                    iconColor: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live report count row
            _LiveReportStatsRow(),

            const SizedBox(height: 24),

            const Text(
              'Specialized Portals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.school_outlined,
                      color: AppColors.primary,
                    ),
                    title: const Text('University Campus Portal'),
                    subtitle: const Text(
                      'DU, BUET, NSU, BRACU desk management',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/university-dashboard'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.corporate_fare_outlined,
                      color: AppColors.secondary,
                    ),
                    title: const Text('Corporate Office Desk'),
                    subtitle: const Text('Lost item logs for offices and hubs'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/office-dashboard'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.flag_outlined,
                      color: AppColors.error,
                    ),
                    title: const Text('Reported Posts'),
                    subtitle: const Text(
                      'Review and moderate community-reported content',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/admin-reports'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live stats row: shows pending reports (live) + flagged/fraud (static).
class _LiveReportStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingReportCountProvider);

    final pendingCount = pendingAsync.maybeWhen(
      data: (v) => v.toString(),
      orElse: () => '—',
    );

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Pending Reports',
            value: pendingCount,
            icon: Icons.assignment_outlined,
            iconColor: AppColors.error,
            onTap: () => context.push('/admin-reports'),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: StatCard(
            title: 'Flagged / Fraud',
            value: '12',
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.orange,
          ),
        ),
      ],
    );
  }
}
