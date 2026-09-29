import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/utils/app_localizations.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    final List<Map<String, String>> pages = [
      {
        'title': isBn ? 'হারানো জিনিস খুঁজে পান' : 'Find What You Lost',
        'desc': isBn
            ? 'চাবি, ওয়ালেট বা শখের জিনিস—সারাদেশের কমিউনিটি আপনার প্রয়োজনীয় জিনিস ফিরিয়ে পেতে সাহায্য করবে।'
            : "Whether it's your keys, wallet, or a beloved pet, our community helps you reunite with your valuables across Bangladesh.",
        'icon': 'find_in_page',
      },
      {
        'title': isBn ? 'অন্যকে সহায়তা করুন' : 'Help Others',
        'desc': isBn
            ? 'কারো মুখে হাসি ফোটান। পাওয়া জিনিস পোস্ট করুন এবং যাচাইকৃত প্ল্যাটফর্মের মাধ্যমে মালিকের কাছে নিরাপদভাবে পৌঁছে দিন।'
            : "Turn someone's bad day around. Report items you find and connect with owners safely through our verified platform.",
        'icon': 'handshake',
      },
      {
        'title': isBn ? 'এআই চালিত ম্যাচিং' : 'AI-Powered Matching',
        'desc': isBn
            ? 'আমাদের স্মার্ট অ্যালগরিদম তাৎক্ষণিকভাবে বর্ণনা ও ছবি স্ক্যান করে হারানো বা প্রাপ্ত আইটেমের সেরা মিল খুঁজে দেয়।'
            : 'Our smart algorithms scan descriptions and photos instantly to find the best match for your lost or found items.',
        'icon': 'auto_awesome',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lost & Found BD',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_currentPage < pages.length - 1)
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(
                isBn ? 'এড়িয়ে যান' : 'Skip',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final item = pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            index == 0
                                ? Icons.search_rounded
                                : index == 1
                                ? Icons.handshake_rounded
                                : Icons.auto_awesome_rounded,
                            size: 90,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicators & Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: _currentPage == pages.length - 1
                        ? (isBn ? 'শুরু করুন' : 'Get Started')
                        : (isBn ? 'পরবর্তী' : 'Next'),
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go('/home');
                      }
                    },
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
