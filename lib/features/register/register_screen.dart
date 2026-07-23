import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptTerms) {
      setState(() => _errorMessage = 'Please accept the Terms & Privacy Policy');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      final cred = await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (cred.user != null) {
        final newUser = UserModel(
          uid: cred.user!.uid,
          email: _emailController.text.trim(),
          displayName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );
        await firestoreService.saveUser(newUser);

        if (mounted) {
          context.go('/onboarding');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Join Lost & Found BD community today.',
                  style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),

                GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          hintText: 'e.g. Tanvir Ahmed',
                          prefixIcon: Icons.person_outline,
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter your full name' : null,
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'tanvir@example.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          hintText: '+8801700000000',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                        ),
                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          validator: (v) {
                            if (v != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptTerms,
                                activeColor: AppColors.primary,
                                onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('/privacy-terms'),
                                child: const Text(
                                  'I agree to the Terms of Service & Privacy Policy',
                                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        PrimaryButton(
                          text: 'Register Account',
                          icon: Icons.check_circle_outline_rounded,
                          isLoading: _isLoading,
                          onPressed: _handleRegister,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
