import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/utils/app_localizations.dart';

class AiMatchResultsScreen extends ConsumerWidget {
  const AiMatchResultsScreen({super.key});

  final List<Map<String, dynamic>> _matches = const [
    {
      'id': '1',
      'title': 'Black Genuine Leather Wallet',
      'location': 'Dhanmondi Road 27, Dhaka',
      'similarity': 96,
      'type': 'found',
      'date': '2 hours ago',
      'image': 'https://picsum.photos/seed/wallet1/200/200',
    },
    {
      'id': '2',
      'title': 'Bifold Leather Wallet with NID',
      'location': 'Farmgate Bus Stand, Dhaka',
      'similarity': 84,
      'type': 'found',
      'date': '5 hours ago',
      'image': 'https://picsum.photos/seed/wallet2/200/200',
    },
    {
      'id': '3',
      'title': 'Brown Card Holder Wallet',
      'location': 'Uttara Sector 10',
      'similarity': 72,
      'type': 'found',
      'date': '1 day ago',
      'image': 'https://picsum.photos/seed/wallet3/200/200',
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'এআই ম্যাচ ফলাফল' : 'AI Match Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isBn
                      ? '৩টি সম্ভাব্য মিল পাওয়া গেছে'
                      : '3 High-Confidence Matches Found',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isBn
                  ? 'জেমিনি এআই ছবির ভেক্টর, রঙের হিস্টোগ্রাম এবং লেখার মিল পরীক্ষা করেছে।'
                  : 'Gemini AI compared visual vectors, color histograms, and OCR text.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.separated(
                itemCount: _matches.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = _matches[index];
                  final similarity = item['similarity'] as int;
                  return GlassContainer(
                    onTap: () => context.push('/item-details/${item['id']}'),
                    borderRadius: 20,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            item['image'],
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: similarity > 90
                                          ? Colors.green
                                          : AppColors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isBn
                                          ? '$similarity% মিল'
                                          : '$similarity% Match',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                    const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: AppColors.outline,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item['location'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.outline,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['date'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                  Text(
                                    isBn
                                        ? 'দাবি / চ্যাট করুন >'
                                        : 'Claim / Chat >',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
