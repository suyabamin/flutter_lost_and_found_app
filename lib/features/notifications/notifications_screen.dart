import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/app_localizations.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).value;
    final authUser = FirebaseAuth.instance.currentUser;
    final firestoreService = ref.watch(firestoreServiceProvider);
    final String currentUserId = user?.uid ?? authUser?.uid ?? 'guest';

    final defaultNotifications = [
      {
        'title': l10n.isBangla
            ? 'এআই ম্যাচ পাওয়া গেছে! (৯৪% সাদৃশ্য)'
            : 'AI Match Found! (94% Similarity)',
        'body': l10n.isBangla
            ? 'ধানমন্ডিতে আপনার রিপোর্টের সাথে মিল থাকা একটি কালো ওয়ালেট পাওয়া গেছে।'
            : 'A black wallet matching your report was found in Dhanmondi.',
        'time': l10n.isBangla ? '১০ মিনিট আগে' : '10 mins ago',
        'type': 'ai_match',
      },
      {
        'title': l10n.isBangla
            ? 'নাঈমুর থেকে নতুন বার্তা'
            : 'New Message from Naimur',
        'body': l10n.isBangla
            ? 'আইফোনটি কি এখনও দাবির জন্য উপলব্ধ?'
            : 'Is the iPhone still available for claim?',
        'time': l10n.isBangla ? '১ ঘণ্টা আগে' : '1 hour ago',
        'type': 'chat',
      },
      {
        'title': l10n.isBangla
            ? 'পুরস্কার অর্জিত +১০০ পয়েন্ট'
            : 'Reward Earned +100 PTS',
        'body': l10n.isBangla
            ? 'আপনি সফলভাবে একটি আইটেম ফেরত যাচাইকরণ সম্পন্ন করেছেন।'
            : 'You completed a successful item return verification.',
        'time': l10n.isBangla ? 'গতকাল' : 'Yesterday',
        'type': 'reward',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('notifications')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.streamNotifications(currentUserId),
        builder: (context, snapshot) {
          final dbNotifications = snapshot.data ?? [];
          final allNotifs = [...dbNotifications, ...defaultNotifications];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: allNotifs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = allNotifs[index];
              final String title = item['title'] ?? l10n.t('notification');
              final String body = item['body'] ?? item['subtitle'] ?? '';
              final String time =
                  item['time'] ?? item['timestamp'] ?? (l10n.isBangla ? 'এইমাত্র' : 'Just now');
              final String? claimId = item['claimId'];
              final String type = item['type'] ?? 'general';

              return GlassContainer(
                onTap: () {
                  if (claimId != null && claimId.isNotEmpty) {
                    context.push('/claim-details/$claimId');
                  } else if (type == 'chat') {
                    context.push('/chats');
                  } else if (type == 'ai_match') {
                    context.push('/ai-matches');
                  }
                },
                borderRadius: 18,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: type == 'claim' || type == 'claim_status'
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        type == 'claim' || type == 'claim_status'
                            ? Icons.assignment_turned_in_rounded
                            : type == 'ai_match'
                            ? Icons.auto_awesome
                            : type == 'chat'
                            ? Icons.chat_rounded
                            : Icons.military_tech_rounded,
                        color: type == 'claim' || type == 'claim_status'
                            ? AppColors.secondary
                            : AppColors.primary,
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
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (type == 'claim' || type == 'claim_status')
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    l10n.t('claim'),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            body,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            time.length > 20 ? time.substring(0, 10) : time,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (claimId != null && claimId.isNotEmpty)
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
