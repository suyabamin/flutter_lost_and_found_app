import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _phoneController = TextEditingController(text: '+8801712345678');
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  bool _codeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _sendOtp() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _codeSent = true;
        });
      }
    });
  }

  void _verifyOtp() {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 6) return;

    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_chat_unread_rounded, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  _codeSent ? 'Enter Verification Code' : 'Phone Authentication',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _codeSent
                      ? 'We sent a 6-digit code to ${_phoneController.text}'
                      : 'Enter your mobile number to receive a verification OTP code.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 28),

                GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (!_codeSent) ...[
                        CustomTextField(
                          controller: _phoneController,
                          labelText: 'Mobile Phone Number',
                          prefixIcon: Icons.phone_android_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          text: 'Send OTP Code',
                          icon: Icons.sms_outlined,
                          isLoading: _isLoading,
                          onPressed: _sendOtp,
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 44,
                              height: 52,
                              child: TextField(
                                controller: _otpControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onChanged: (val) {
                                  if (val.isNotEmpty && index < 5) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Verify & Continue',
                          icon: Icons.check_circle_outline,
                          isLoading: _isLoading,
                          onPressed: _verifyOtp,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => setState(() => _codeSent = false),
                          child: const Text('Change Phone Number'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
