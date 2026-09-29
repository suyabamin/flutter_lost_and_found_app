import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/utils/app_localizations.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  final List<Map<String, String>> _faqsEn = const [
    {
      'question': 'How does AI Visual & Text Matching work?',
      'answer':
          'Gemini AI automatically processes uploaded image feature vectors, color histograms, and OCR text to calculate match confidence between lost and found reports.',
    },
    {
      'question': 'How do I claim a lost item safely?',
      'answer':
          'Verify your NID first, then open a direct realtime chat with the reporter. Provide proof of ownership before meeting in a safe public area or police thana.',
    },
    {
      'question': 'How does Bangladesh Police E-GD integration work?',
      'answer':
          'You can auto-fill a standardized e-GD form with your NID credentials and download a printable PDF to submit directly at your local police station.',
    },
  ];

  final List<Map<String, String>> _faqsBn = const [
    {
      'question': 'এআই ভিজ্যুয়াল ও টেক্সট ম্যাচিং কীভাবে কাজ করে?',
      'answer':
          'জেমিনাই এআই আপলোড করা ছবির বৈশিষ্ট্য, রঙের বিন্যাস এবং ওসিআর টেক্সট স্বয়ংক্রিয়ভাবে বিশ্লেষণ করে হারানো ও পাওয়া রিপোর্টের মধ্যে মিলের সম্ভাব্যতা হিসাব করে।',
    },
    {
      'question': 'হারানো আইটেম কীভাবে নিরাপদে দাবি করব?',
      'answer':
          'প্রথমে আপনার এনআইডি যাচাই করুন, তারপর প্রতিবেদকের সাথে রিয়েল-টাইম চ্যাট শুরু করুন। নিরাপদ প্রকাশ্য স্থান বা পুলিশ থানায় সাক্ষাতের আগে মালিকানার উপযুক্ত প্রমাণ দিন।',
    },
    {
      'question': 'বাংলাদেশ পুলিশ ই-জিডি সেবা কীভাবে কাজ করে?',
      'answer':
          'আপনি আপনার এনআইডি তথ্য দিয়ে একটি প্রমিত ই-জিডি ফর্ম স্বয়ংক্রিয়ভাবে পূরণ করতে পারেন এবং প্রিন্টযোগ্য পিডিএফ ডাউনলোড করে সরাসরি স্থানীয় থানায় জমা দিতে পারেন।',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;
    final faqs = isBn ? _faqsBn : _faqsEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'সহায়তা কেন্দ্র ও সাধারণ জিজ্ঞাসা' : 'Help Center & FAQs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = faqs[index];
          return GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            child: ExpansionTile(
              title: Text(
                item['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    item['answer']!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
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
