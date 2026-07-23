import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/providers/providers.dart';

class WelcomeAuthScreen extends ConsumerWidget {
  const WelcomeAuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background soft blurs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.12),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Logo Icon Block
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.find_in_page_rounded,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Lost & Found BD',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Reconnecting you with what matters most, anywhere in Bangladesh.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Action Glass Card
                    GlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Continue with Google Button
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: const BorderSide(color: AppColors.outlineVariant),
                              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                            ),
                            onPressed: () async {
                              final cred = await authService.signInWithGoogle();
                              if (cred != null && context.mounted) {
                                context.go('/home');
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                                  width: 22,
                                  height: 22,
                                  errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Continue with Phone Button
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              side: const BorderSide(color: AppColors.outlineVariant),
                              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                            ),
                            onPressed: () => context.push('/otp-verify'),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone, color: AppColors.primary, size: 22),
                                SizedBox(width: 12),
                                Text(
                                  'Continue with Phone',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Expanded(child: Divider(color: AppColors.outlineVariant)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('OR', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                              ),
                              Expanded(child: Divider(color: AppColors.outlineVariant)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Login with Email Button
                          PrimaryButton(
                            text: 'Login with Email',
                            icon: Icons.email_outlined,
                            onPressed: () => context.push('/login'),
                          ),
                          const SizedBox(height: 16),

                          // Register Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? ", style: TextStyle(fontSize: 14)),
                              GestureDetector(
                                onTap: () => context.push('/register'),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'By continuing, you agree to our Terms of Service & Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
