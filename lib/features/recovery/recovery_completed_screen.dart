import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/models/claim_model.dart';
import '../../core/models/post_model.dart';
import '../../core/models/recovery_models.dart';
import '../../core/providers/providers.dart';

class RecoveryCompletedScreen extends ConsumerWidget {
  final String claimId;

  const RecoveryCompletedScreen({super.key, required this.claimId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestoreService = ref.watch(firestoreServiceProvider);
    final authUser = FirebaseAuth.instance.currentUser;
    final currentUid = authUser?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recovery Completed 🎉'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<ClaimModel?>(
        stream: firestoreService.streamClaim(claimId),
        builder: (context, snapshot) {
          final claim = snapshot.data;
          if (claim == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isOwner = currentUid == claim.postOwnerId;

          return FutureBuilder<PostModel?>(
            future: firestoreService.getPost(claim.postId),
            builder: (context, postSnapshot) {
              final post = postSnapshot.data;
              final rewardAmount = post?.rewardAmount ?? claim.rewardRequested;

              return StreamBuilder<PaymentModel?>(
                stream: firestoreService.streamPaymentForClaim(claimId),
                builder: (context, paymentSnapshot) {
                  final payment = paymentSnapshot.data;
                  final isPaid = payment != null && (payment.status == 'paid' || payment.status == 'completed');
                  final isPaymentCompleted = payment != null && payment.status == 'completed';

                  return StreamBuilder<RatingModel?>(
                    stream: firestoreService.streamUserRatingForClaim(claimId, currentUid),
                    builder: (context, ratingSnapshot) {
                      final hasRated = ratingSnapshot.data != null;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            // Celebration Header Icon
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.green, width: 3),
                              ),
                              child: const Center(
                                child: Icon(Icons.verified_rounded, color: Colors.green, size: 64),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Item Successfully Recovered!',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Both parties have confirmed item handoff.',
                              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Item Summary Card
                            GlassContainer(
                              borderRadius: 20,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.grey.shade200,
                                          image: post != null && post.images.isNotEmpty
                                              ? DecorationImage(image: NetworkImage(post.images.first), fit: BoxFit.cover)
                                              : null,
                                        ),
                                        child: post == null || post.images.isEmpty
                                            ? const Icon(Icons.category_rounded, color: AppColors.primary)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post?.title ?? 'Recovered Item',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Category: ${post?.category ?? "General"}',
                                              style: const TextStyle(fontSize: 12, color: AppColors.outline),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Claimer / Finder:', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                                      Text(claim.claimerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Reward Amount:', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                                      Text(
                                        rewardAmount > 0 ? '৳ ${rewardAmount.round()}' : 'No Reward Set',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: rewardAmount > 0 ? AppColors.secondary : AppColors.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Payment Status:', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: (isPaymentCompleted || rewardAmount == 0)
                                              ? Colors.green.withOpacity(0.15)
                                              : (isPaid ? Colors.orange.withOpacity(0.15) : AppColors.error.withOpacity(0.15)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          rewardAmount == 0
                                              ? 'No Reward'
                                              : (isPaymentCompleted ? 'COMPLETED' : (isPaid ? 'PAID - PENDING CONFIRM' : 'UNPAID')),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: (isPaymentCompleted || rewardAmount == 0)
                                                ? Colors.green
                                                : (isPaid ? Colors.orange : AppColors.error),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ACTION BUTTONS BASED ON ROLE & REWARD STATUS
                            if (isOwner && rewardAmount > 0 && !isPaid) ...[
                              PrimaryButton(
                                text: 'Pay Reward (৳ ${rewardAmount.round()})',
                                icon: Icons.payments_rounded,
                                onPressed: () => context.push('/reward-payment/$claimId'),
                              ),
                              const SizedBox(height: 12),
                            ],

                            if (!isOwner && isPaid && !isPaymentCompleted) ...[
                              GlassContainer(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    Text(
                                      'Owner has sent ৳ ${payment?.amount.toInt()} via ${payment?.method}.',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Trx ID: ${payment?.transactionId}', style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                                    const SizedBox(height: 12),
                                    PrimaryButton(
                                      text: 'Confirm Reward Received',
                                      icon: Icons.check_circle_outline_rounded,
                                      onPressed: () async {
                                        if (payment != null) {
                                          await firestoreService.confirmPaymentReceived(payment.paymentId);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('🎉 Reward confirmed! Added to your wallet.')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // RATING BUTTON
                            if (!hasRated) ...[
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () => context.push('/rating/$claimId'),
                                icon: const Icon(Icons.star_rate_rounded, color: Colors.amber),
                                label: const Text('Rate & Review User', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 12),
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.amber, size: 18),
                                    SizedBox(width: 8),
                                    Text('You have submitted a review for this recovery.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // VIEW HISTORY / HOME
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () => context.push('/recovery-history'),
                                    icon: const Icon(Icons.history_rounded, size: 18),
                                    label: const Text('Recovery History'),
                                  ),
                                ),
                                if (rewardAmount > 0)
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () => context.push('/wallet'),
                                      icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
                                      label: const Text('My Wallet'),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
