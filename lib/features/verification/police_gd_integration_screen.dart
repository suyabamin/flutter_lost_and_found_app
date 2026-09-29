import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/app_localizations.dart';

class PoliceGdIntegrationScreen extends ConsumerStatefulWidget {
  const PoliceGdIntegrationScreen({super.key});

  @override
  ConsumerState<PoliceGdIntegrationScreen> createState() =>
      _PoliceGdIntegrationScreenState();
}

class _PoliceGdIntegrationScreenState
    extends ConsumerState<PoliceGdIntegrationScreen> {
  final _thanaController = TextEditingController(
    text: 'Dhanmondi Model Thana, Dhaka',
  );
  final _incidentDescController = TextEditingController();
  final _imeiController = TextEditingController();
  bool _isGenerating = false;

  void _generateGdPdf() {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    setState(() => _isGenerating = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn
                  ? 'অফিসিয়াল সাধারণ ডায়েরি (জিডি) খসড়া সফলভাবে তৈরি হয়েছে!'
                  : 'Official General Diary (GD) draft generated successfully!',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBn ? 'পুলিশ জিডি সেবা' : 'Police GD Integration'),
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
            Row(
              children: [
                const Icon(
                  Icons.local_police_rounded,
                  size: 36,
                  color: Colors.indigo,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn
                            ? 'বাংলাদেশ পুলিশ ই-জিডি ফরম্যাট'
                            : 'Bangladesh Police E-GD Format',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isBn
                            ? 'অফিসিয়াল ফাইলিংয়ের জন্য সাধারণ ডায়েরি ফর্ম পূরণ'
                            : 'Auto-fill General Diary form for official filing',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _thanaController,
                    labelText: isBn ? 'নিকটবর্তী পুলিশ থানা' : 'Nearest Police Thana',
                    prefixIcon: Icons.account_balance_rounded,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _imeiController,
                    labelText: isBn
                        ? 'আইএমইআই / সিরিয়াল / নথি নম্বর (ঐচ্ছিক)'
                        : 'IMEI / Serial / Document Ref # (Optional)',
                    hintText: 'e.g. 356789012345678',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _incidentDescController,
                    labelText: isBn ? 'ঘটনার বিস্তারিত বিবরণ' : 'Detailed Statement of Occurrence',
                    hintText: isBn
                        ? 'সঠিক সময়, অবস্থান এবং পরিস্থিতি উল্লেখ করুন...'
                        : 'Provide precise timeline, location, and circumstances...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: isBn
                  ? 'অফিসিয়াল জিডি ডকুমেন্ট তৈরি করুন (PDF)'
                  : 'Generate Official GD Document (PDF)',
              icon: Icons.picture_as_pdf_rounded,
              color: Colors.indigo,
              isLoading: _isGenerating,
              onPressed: _generateGdPdf,
            ),
          ],
        ),
      ),
    );
  }
}
