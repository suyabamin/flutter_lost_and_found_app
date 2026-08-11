import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/models/recovery_models.dart';
import '../../core/providers/providers.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final authUser = FirebaseAuth.instance.currentUser;
    final currentUid = authUser?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Earnings & Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<WalletModel?>(
        stream: firestoreService.streamWallet(currentUid),
        builder: (context, walletSnapshot) {
          final wallet = walletSnapshot.data ?? WalletModel(userId: currentUid);

          return StreamBuilder<List<PaymentModel>>(
            stream: firestoreService.streamUserPayments(currentUid),
            builder: (context, paymentsSnapshot) {
              final payments = paymentsSnapshot.data ?? [];

              // Calculate dynamic earnings from payment history for finder
              final now = DateTime.now();
              double totalCalc = 0.0;
              double todayCalc = 0.0;
              double monthCalc = 0.0;

              for (final p in payments) {
                if (p.finderId == currentUid && (p.status == 'paid' || p.status == 'completed')) {
                  totalCalc += p.amount;
                  if (p.paidAt.year == now.year && p.paidAt.month == now.month && p.paidAt.day == now.day) {
                    todayCalc += p.amount;
                  }
                  if (p.paidAt.year == now.year && p.paidAt.month == now.month) {
                    monthCalc += p.amount;
                  }
                }
              }

              final displayTotal = wallet.totalEarned > 0 ? wallet.totalEarned.toInt() : totalCalc.toInt();
              final displayToday = wallet.todayEarned > 0 ? wallet.todayEarned.toInt() : todayCalc.toInt();
              final displayMonthly = wallet.monthlyEarned > 0 ? wallet.monthlyEarned.toInt() : monthCalc.toInt();
              final displayLifetime = wallet.lifetimeEarned > 0 ? wallet.lifetimeEarned.toInt() : totalCalc.toInt();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Balance Hero Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Reward Earnings',
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                              Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '৳ $displayTotal',
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Payout request feature enabled for verified accounts.')),
                              );
                            },
                            icon: const Icon(Icons.outbox_rounded, size: 18),
                            label: const Text('Withdraw Earnings (Future Use)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Stats Grid (Today, Monthly, Lifetime)
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Today',
                            value: '৳ $displayToday',
                            icon: Icons.today_rounded,
                            iconColor: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'This Month',
                            value: '৳ $displayMonthly',
                            icon: Icons.calendar_month_rounded,
                            iconColor: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StatCard(
                      title: 'Lifetime Earned Rewards',
                      value: '৳ $displayLifetime',
                      icon: Icons.workspace_premium_rounded,
                      iconColor: Colors.amber,
                    ),
                    const SizedBox(height: 24),

                    // Reward Payment History Section
                    const Text('Transaction & Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    if (payments.isEmpty)
                      GlassContainer(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: const [
                              Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.outline),
                              SizedBox(height: 10),
                              Text('No transactions yet.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              SizedBox(height: 4),
                              Text('Received and paid rewards will be listed here.', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: payments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final p = payments[index];
                          final isEarned = p.finderId == currentUid;

                          return GlassContainer(
                            borderRadius: 16,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isEarned ? Colors.green.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isEarned ? Icons.south_west_rounded : Icons.north_east_rounded,
                                    color: isEarned ? Colors.green : AppColors.error,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isEarned ? 'Reward Received (${p.method})' : 'Reward Paid (${p.method})',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'TrxID: ${p.transactionId}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.outline),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${isEarned ? "+" : "-"}৳ ${p.amount.toInt()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isEarned ? Colors.green : AppColors.error,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: p.status == 'completed' ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        p.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: p.status == 'completed' ? Colors.green : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
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
