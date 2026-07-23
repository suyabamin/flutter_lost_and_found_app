import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';

class PoliceGdIntegrationScreen extends ConsumerStatefulWidget {
  const PoliceGdIntegrationScreen({super.key});

  @override
  ConsumerState<PoliceGdIntegrationScreen> createState() => _PoliceGdIntegrationScreenState();
}

class _PoliceGdIntegrationScreenState extends ConsumerState<PoliceGdIntegrationScreen> {
  final _thanaController = TextEditingController(text: 'Dhanmondi Model Thana, Dhaka');
  final _incidentDescController = TextEditingController();
  final _imeiController = TextEditingController();
  bool _isGenerating = false;

  void _generateGdPdf() {
    setState(() => _isGenerating = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Official General Diary (GD) draft generated successfully!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police GD Integration'),
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
              children: const [
                Icon(Icons.local_police_rounded, size: 36, color: Colors.indigo),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bangladesh Police E-GD Format', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Auto-fill General Diary form for official filing', style: TextStyle(fontSize: 12, color: AppColors.outline)),
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
                    labelText: 'Nearest Police Thana',
                    prefixIcon: Icons.account_balance_rounded,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _imeiController,
                    labelText: 'IMEI / Serial / Document Ref # (Optional)',
                    hintText: 'e.g. 356789012345678',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _incidentDescController,
                    labelText: 'Detailed Statement of Occurrence',
                    hintText: 'Provide precise timeline, location, and circumstances...',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Generate Official GD Document (PDF)',
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
