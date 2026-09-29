import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/app_localizations.dart';

class NidVerificationScreen extends ConsumerStatefulWidget {
  const NidVerificationScreen({super.key});

  @override
  ConsumerState<NidVerificationScreen> createState() =>
      _NidVerificationScreenState();
}

class _NidVerificationScreenState extends ConsumerState<NidVerificationScreen> {
  final _nidController = TextEditingController();
  final _dobController = TextEditingController();
  File? _nidFrontImage;
  File? _nidBackImage;
  bool _isSubmitting = false;

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isFront) {
          _nidFrontImage = File(picked.path);
        } else {
          _nidBackImage = File(picked.path);
        }
      });
    }
  }

  void _submitNid() {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn
                  ? 'এনআইডি ডকুমেন্ট যাচাইয়ের জন্য জমা দেওয়া হয়েছে!'
                  : 'NID Documents submitted for verification!',
            ),
          ),
        );
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'স্মার্ট এনআইডি যাচাইকরণ' : 'NID Smart Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBn ? 'বাংলাদেশ এনআইডি যাচাই করুন' : 'Verify Bangladesh NID',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isBn
                  ? 'তাৎক্ষণিক ট্রাস্ট ব্যাজ পান, উচ্চতর পুরস্কার আনলক করুন এবং নিরাপদ পুলিশ জিডি সুবিধা পান।'
                  : 'Gain instant Trust Badge, unlock higher rewards, and secure direct police GD generation.',
              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nidController,
                    labelText: isBn ? 'জাতীয় পরিচয়পত্র নম্বর (এনআইডি)' : 'National ID Number (NID)',
                    hintText: isBn ? '১০ বা ১৭ ডিজিটের এনআইডি নম্বর' : '10 or 17 digit NID number',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _dobController,
                    labelText: isBn ? 'জন্ম তারিখ' : 'Date of Birth',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: Icons.calendar_month,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              isBn ? 'এনআইডি কার্ডের ছবি আপলোড করুন' : 'Upload NID Card Photos',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickImage(true),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: _nidFrontImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _nidFrontImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.badge,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isBn ? 'এনআইডি সামনের দিক' : 'NID Front Side',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickImage(false),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: _nidBackImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _nidBackImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isBn ? 'এনআইডি পেছনের দিক' : 'NID Back Side',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            PrimaryButton(
              text: isBn ? 'এনআইডি যাচাইয়ের জন্য জমা দিন' : 'Submit for NID Verification',
              icon: Icons.verified_user_rounded,
              isLoading: _isSubmitting,
              onPressed: _submitNid,
            ),
          ],
        ),
      ),
    );
  }
}
