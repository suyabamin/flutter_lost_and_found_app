import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/models/claim_model.dart';
import '../../core/models/post_model.dart';
import '../../core/models/recovery_models.dart';
import '../../core/providers/providers.dart';

class RewardPaymentScreen extends ConsumerStatefulWidget {
  final String claimId;

  const RewardPaymentScreen({super.key, required this.claimId});

  @override
  ConsumerState<RewardPaymentScreen> createState() => _RewardPaymentScreenState();
}

class _RewardPaymentScreenState extends ConsumerState<RewardPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trxIdController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverNumberController = TextEditingController();

  String _selectedMethod = 'bKash';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _trxIdController.dispose();
    _receiverNameController.dispose();
    _receiverNumberController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment(ClaimModel claim, double amount) async {
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final authUser = FirebaseAuth.instance.currentUser;
      final currentUid = authUser?.uid ?? 'guest';

      final paymentId = 'pay_${DateTime.now().millisecondsSinceEpoch}';

      final payment = PaymentModel(
        paymentId: paymentId,
        postId: claim.postId,
        claimId: widget.claimId,
        posterId: currentUid,
        finderId: claim.claimerId,
        method: _selectedMethod,
        amount: amount,
        receiverName: _receiverNameController.text.trim().isNotEmpty
            ? _receiverNameController.text.trim()
            : claim.claimerName,
        receiverNumber: _receiverNumberController.text.trim().isNotEmpty
            ? _receiverNumberController.text.trim()
            : claim.claimerPhone,
        transactionId: _trxIdController.text.trim().toUpperCase(),
        status: 'paid',
        paidAt: DateTime.now(),
      );

      await firestoreService.createPayment(payment);

      if (mounted) {
        context.pushReplacement('/reward-success/$paymentId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment processing error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<ClaimModel?>(
        stream: firestoreService.streamClaim(widget.claimId),
        builder: (context, snapshot) {
          final claim = snapshot.data;
          if (claim == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<PostModel?>(
            future: firestoreService.getPost(claim.postId),
            builder: (context, postSnapshot) {
              final post = postSnapshot.data;
              final amount = post?.rewardAmount ?? claim.rewardRequested;

              if (_receiverNameController.text.isEmpty) {
                _receiverNameController.text = claim.claimerName;
              }
              if (_receiverNumberController.text.isEmpty && claim.claimerPhone.isNotEmpty) {
                _receiverNumberController.text = claim.claimerPhone;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Summary
                      GlassContainer(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const Text('Total Reward Amount', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                            const SizedBox(height: 4),
                            Text(
                              '৳ ${amount.round()}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reward for item: "${post?.title ?? "Recovered Item"}"',
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      // Method Selector Chips (bKash, Rocket, Nagad)
                      Row(
                        children: ['bKash', 'Rocket', 'Nagad'].map((m) {
                          final isSelected = _selectedMethod == m;
                          Color badgeColor = m == 'bKash'
                              ? Colors.pink
                              : (m == 'Rocket' ? Colors.purple : Colors.orange);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => setState(() => _selectedMethod = m),
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSelected ? badgeColor.withOpacity(0.15) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? badgeColor : AppColors.outlineVariant,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        m == 'bKash'
                                            ? Icons.account_balance_wallet_rounded
                                            : (m == 'Rocket' ? Icons.rocket_launch_rounded : Icons.flash_on_rounded),
                                        color: badgeColor,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        m,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSelected ? badgeColor : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      GlassContainer(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: _receiverNameController,
                              labelText: 'Receiver Name (Finder)',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter receiver name' : null,
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _receiverNumberController,
                              labelText: 'Receiver Phone Number',
                              prefixIcon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v == null || v.trim().isEmpty ? 'Enter receiver number' : null,
                            ),
                            const SizedBox(height: 14),
                            CustomTextField(
                              controller: _trxIdController,
                              labelText: 'Transaction ID (TrxID)',
                              hintText: 'e.g. 9J87A2KXLM',
                              prefixIcon: Icons.receipt_long_rounded,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Transaction ID is required';
                                }
                                if (v.trim().length < 6) {
                                  return 'Enter a valid Transaction ID';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      PrimaryButton(
                        text: 'Confirm & Submit Payment',
                        icon: Icons.check_circle_rounded,
                        isLoading: _isSubmitting,
                        onPressed: () => _submitPayment(claim, amount),
                      ),
                      const SizedBox(height: 12),

                      Center(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Cancel Payment', style: TextStyle(color: AppColors.outline)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
