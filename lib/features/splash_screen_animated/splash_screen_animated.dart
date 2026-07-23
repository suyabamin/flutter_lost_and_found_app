import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class SplashScreenAnimatedScreen extends ConsumerStatefulWidget {
  const SplashScreenAnimatedScreen({super.key});

  @override
  ConsumerState<SplashScreenAnimatedScreen> createState() => _SplashScreenAnimatedScreenState();
}

class _SplashScreenAnimatedScreenState extends ConsumerState<SplashScreenAnimatedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Stack(
            children: [
              // Dynamic Animated Shader/Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.darkBackground,
                            Color.lerp(AppColors.darkSurface, AppColors.primary, _bgController.value * 0.2)!,
                            AppColors.darkBackground,
                          ]
                        : [
                            Color.lerp(AppColors.primaryContainer.withOpacity(0.2), AppColors.secondaryContainer.withOpacity(0.3), _bgController.value)!,
                            AppColors.background,
                            Color.lerp(AppColors.secondaryContainer.withOpacity(0.3), AppColors.primaryContainer.withOpacity(0.2), _bgController.value)!,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      // Animated Glass Logo Container
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: GlassContainer(
                          borderRadius: 100,
                          blur: 25,
                          padding: const EdgeInsets.all(32),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        'Lost & Found BD',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'RELIABILITY • EFFICIENCY • CALM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      // Animated Loader Bar
                      Container(
                        width: 140,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 140 * _bgController.value,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Connecting you back to what matters...',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.outline),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
