import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/models/recovery_models.dart';
import '../../core/providers/providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity & Recovery History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<List<HistoryModel>>(
        stream: firestoreService.streamUserHistory(currentUid),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const Center(
              child: Text('No Recovery History Yet', style: TextStyle(fontWeight: FontWeight.bold)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final isOwner = currentUid == item.posterId || currentUid == item.ownerId;
              final partnerName = isOwner ? item.finderName : item.ownerName;
              final ratingGiven = isOwner ? item.ownerRating : item.finderRating;
              final reviewText = isOwner ? item.ownerReview : item.finderReview;

              return GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(isOwner ? Icons.inbox_rounded : Icons.task_alt_rounded, color: isOwner ? AppColors.primary : Colors.green),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Cat: ${item.category} • Partner: $partnerName', style: const TextStyle(fontSize: 11, color: AppColors.outline)),
                            ],
                          ),
                        ),
                        Text('${item.completedDate.day}/${item.completedDate.month}/${item.completedDate.year}', style: const TextStyle(fontSize: 11, color: AppColors.outline)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (item.rewardAmount > 0)
                          Text('Reward: ৳${item.rewardAmount.toInt()}  ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOwner ? AppColors.error : Colors.green)),
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        Text(' $ratingGiven / 5', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    if (reviewText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Review: "$reviewText"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                    ],
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
