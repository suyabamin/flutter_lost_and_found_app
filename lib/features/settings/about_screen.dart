import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/utils/app_localizations.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'লস্ট অ্যান্ড ফাউন্ড বিডি সম্পর্কে' : 'About Lost & Found BD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.find_in_page_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isBn ? 'লস্ট অ্যান্ড ফাউন্ড বাংলাদেশ' : 'Lost & Found Bangladesh',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isBn ? 'সংস্করণ ১.০.০ (প্রোডাকশন বিল্ড)' : 'Version 1.0.0 (Production Build)',
              style: const TextStyle(color: AppColors.outline, fontSize: 13),
            ),
            const SizedBox(height: 24),

            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'লক্ষ্য ও উদ্দেশ্য' : 'Mission & Vision',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn
                        ? 'লস্ট অ্যান্ড ফাউন্ড বিডি হলো বাংলাদেশের জাতীয় এআই-চালিত পুনরুদ্ধার নেটওয়ার্ক যা নাগরিক, বিশ্ববিদ্যালয়, করপোরেট অফিস এবং আইন প্রয়োগকারী সংস্থাকে দ্রুত ও নিরাপদ আইটেম পুনরুদ্ধারের জন্য সংযুক্ত করে।'
                        : 'Lost & Found BD is Bangladesh’s national AI-powered recovery network connecting citizens, universities, corporate offices, and law enforcement for fast, secure item restoration.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
