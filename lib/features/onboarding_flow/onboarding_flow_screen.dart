import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';

class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Find What You Lost',
      'desc': "Whether it's your keys, wallet, or a beloved pet, our community helps you reunite with your valuables across Bangladesh.",
      'icon': 'find_in_page',
    },
    {
      'title': 'Help Others',
      'desc': "Turn someone's bad day around. Report items you find and connect with owners safely through our verified platform.",
      'icon': 'handshake',
    },
    {
      'title': 'AI-Powered Matching',
      'desc': 'Our smart algorithms scan descriptions and photos instantly to find the best match for your lost or found items.',
      'icon': 'auto_awesome',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found BD', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        actions: [
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: () => context.go('/home'),
              child: const Text('Skip', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final item = _pages[index];
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
                            color: AppColors.primary.withOpacity(0.1),
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
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant, height: 1.4),
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
                    children: List.generate(_pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
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
