import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How does AI Visual & Text Matching work?',
      'answer': 'Gemini AI automatically processes uploaded image feature vectors, color histograms, and OCR text to calculate match confidence between lost and found reports.',
    },
    {
      'question': 'How do I claim a lost item safely?',
      'answer': 'Verify your NID first, then open a direct realtime chat with the reporter. Provide proof of ownership before meeting in a safe public area or police thana.',
    },
    {
      'question': 'How does Bangladesh Police E-GD integration work?',
      'answer': 'You can auto-fill a standardized e-GD form with your NID credentials and download a printable PDF to submit directly at your local police station.',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center & FAQs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _faqs[index];
          return GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(16),
            child: ExpansionTile(
              title: Text(item['question']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(item['answer']!, style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.4)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
