import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/models/recovery_models.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/app_localizations.dart';

class RewardSuccessScreen extends ConsumerWidget {
  final String paymentId;

  const RewardSuccessScreen({super.key, required this.paymentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(isBn ? 'পেমেন্ট জমা হয়েছে' : 'Payment Submitted'),
      ),
      body: StreamBuilder<PaymentModel?>(
        stream: firestoreService.streamPayment(paymentId),
        builder: (context, snapshot) {
          final payment = snapshot.data;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 54,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isBn
                      ? 'পুরস্কার পেমেন্ট জমা দেওয়া হয়েছে!'
                      : 'Reward Payment Submitted!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isBn
                      ? 'উদ্ধারকারীকে নোটিফিকেশন পাঠানো হয়েছে। উদ্ধারকারী গ্রহণ নিশ্চিত করলে পুনরুদ্ধার চূড়ান্ত হবে।'
                      : 'Notification sent to Finder. Once Finder confirms receipt, recovery will be finalized.',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'ট্রানজেকশন আইডি:' : 'Transaction ID:',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.outline,
                            ),
                          ),
                          Text(
                            payment?.transactionId ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'পদ্ধতি ও পরিমাণ:' : 'Method & Amount:',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.outline,
                            ),
                          ),
                          Text(
                            '${payment?.method ?? "bKash"} • ৳ ${payment?.amount.toInt() ?? 0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'প্রাপক:' : 'Receiver:',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.outline,
                            ),
                          ),
                          Text(
                            payment?.receiverName ??
                                (isBn ? 'উদ্ধারকারী' : 'Finder'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'স্ট্যাটাস:' : 'Status:',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.outline,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isBn
                                  ? 'পরিশোধিত (উদ্ধারকারীর অপেক্ষমাণ)'
                                  : 'PAID (Awaiting Finder)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  text: isBn
                      ? 'পুনরুদ্ধার সারসংক্ষেপে ফিরুন'
                      : 'Back to Recovery Summary',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () {
                    if (payment != null && payment.claimId.isNotEmpty) {
                      context.pushReplacement(
                        '/recovery-completed/${payment.claimId}',
                      );
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
