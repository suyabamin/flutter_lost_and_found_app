import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/utils/app_localizations.dart';

class PrivacyTermsScreen extends ConsumerWidget {
  const PrivacyTermsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'গোপনীয়তা ও শর্তাবলী' : 'Privacy & Terms'),
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
            children: [
              Text(
                isBn ? 'গোপনীয়তা নীতি ও ব্যবহারের শর্তাবলী' : 'Privacy Policy & User Terms',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                isBn
                    ? '১. তথ্যের গোপনীয়তা ও নিরাপত্তা\nআমরা ব্যবহারকারীর তথ্য কঠোরভাবে সুরক্ষিত রাখি। আপনার এনআইডি তথ্য এনক্রিপ্ট করা হয় এবং শুধুমাত্র পরিচয় যাচাইয়ের জন্য ব্যবহৃত হয়।\n\n'
                      '২. রিপোর্টের নির্ভুলতা\nভুয়া বা প্রতারণামূলক হারানো ও পাওয়া রিপোর্ট প্রদান করলে তাৎক্ষণিকভাবে অ্যাকাউন্ট স্থগিত করা হবে এবং আইন প্রয়োগকারী সংস্থাকে অবহিত করা হবে।\n\n'
                      '৩. অবস্থান ও জিপিএস\nনিকটবর্তী আইটেম দেখানোর জন্য অবস্থানের স্থানাঙ্ক অনুরোধ করা হয় এবং ব্যবহারকারীর সম্মতি ছাড়া তা কখনই প্রকাশ্যে শেয়ার করা হয় না।\n\n'
                      '৪. পুরস্কার ও পেমেন্ট\nবিকাশ বা নগদের মাধ্যমে সকল পুরস্কার লেনদেন প্রত্যয়িত পেমেন্ট গেটওয়ের মাধ্যমে নিরাপদে সম্পন্ন হয়।'
                    : '1. Data Privacy & Safety\nWe strictly protect user data. Your NID details are encrypted and used solely for identity verification.\n\n'
                      '2. Report Accuracy\nFalse or fraudulent lost & found reports will result in instant account suspension and referral to Bangladesh Law Enforcement.\n\n'
                      '3. Location & GPS\nLocation coordinates are requested to show nearby items and are never shared publicly without user consent.\n\n'
                      '4. Rewards & Payments\nAll reward transactions via bKash or Nagad are processed securely through certified payment gateways.',
                style: const TextStyle(
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
