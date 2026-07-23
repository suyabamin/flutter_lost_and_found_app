import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, String>> _notifications = const [
    {
      'title': 'AI Match Found! (94% Similarity)',
      'subtitle': 'A black wallet matching your report was found in Dhanmondi.',
      'time': '10 mins ago',
      'icon': 'auto_awesome',
    },
    {
      'title': 'New Message from Naimur',
      'subtitle': 'Is the iPhone still available for claim?',
      'time': '1 hour ago',
      'icon': 'chat',
    },
    {
      'title': 'Reward Earned +100 PTS',
      'subtitle': 'You completed a successful item return verification.',
      'time': 'Yesterday',
      'icon': 'military_tech',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    item['icon'] == 'auto_awesome'
                        ? Icons.auto_awesome
                        : item['icon'] == 'chat'
                            ? Icons.chat_rounded
                            : Icons.military_tech_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(item['subtitle']!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(item['time']!, style: const TextStyle(fontSize: 10, color: AppColors.outline)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
