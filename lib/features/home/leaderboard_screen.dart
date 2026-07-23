import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  final List<Map<String, dynamic>> _rankings = const [
    {'name': 'Tanvir Ahmed', 'points': 2450, 'rank': 1, 'avatar': 'https://i.pravatar.cc/100?img=11'},
    {'name': 'Naimur Rahman', 'points': 2100, 'rank': 2, 'avatar': 'https://i.pravatar.cc/100?img=12'},
    {'name': 'Sadia Islam', 'points': 1890, 'rank': 3, 'avatar': 'https://i.pravatar.cc/100?img=16'},
    {'name': 'Arif Hasan', 'points': 1420, 'rank': 4, 'avatar': 'https://i.pravatar.cc/100?img=33'},
    {'name': 'Mehedi Hasan', 'points': 1180, 'rank': 5, 'avatar': 'https://i.pravatar.cc/100?img=53'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _rankings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _rankings[index];
          final rank = item['rank'] as int;
          return GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: rank == 1
                      ? Colors.amber
                      : rank == 2
                          ? Colors.grey.shade400
                          : rank == 3
                              ? Colors.brown.shade300
                              : AppColors.outlineVariant,
                  child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(item['avatar']),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Verified Hero', style: TextStyle(fontSize: 11, color: AppColors.outline)),
                    ],
                  ),
                ),
                Text(
                  '${item['points']} PTS',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
