import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class PrivacyTermsScreen extends ConsumerWidget {
  const PrivacyTermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Terms'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Privacy Policy & User Terms',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '1. Data Privacy & Safety\nWe strictly protect user data. Your NID details are encrypted and used solely for identity verification.\n\n'
                '2. Report Accuracy\nFalse or fraudulent lost & found reports will result in instant account suspension and referral to Bangladesh Law Enforcement.\n\n'
                '3. Location & GPS\nLocation coordinates are requested to show nearby items and are never shared publicly without user consent.\n\n'
                '4. Rewards & Payments\nAll reward transactions via bKash or Nagad are processed securely through certified payment gateways.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
