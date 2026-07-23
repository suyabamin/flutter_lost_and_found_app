import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';

class AiImageScanScreen extends ConsumerStatefulWidget {
  const AiImageScanScreen({super.key});

  @override
  ConsumerState<AiImageScanScreen> createState() => _AiImageScanScreenState();
}

class _AiImageScanScreenState extends ConsumerState<AiImageScanScreen> {
  File? _selectedImage;
  bool _isScanning = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _runAiScan() {
    if (_selectedImage == null) return;
    setState(() => _isScanning = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isScanning = false);
        context.push('/ai-matches');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Visual Scan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Scan & Compare Image',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Upload a photo of your lost or found item. Gemini AI will scan features and compare with all database records.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(16),
                  child: _selectedImage != null
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                            ),
                            if (_isScanning)
                              Container(
                                color: Colors.black45,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    CircularProgressIndicator(color: Colors.white),
                                    SizedBox(height: 16),
                                    Text(
                                      'Analyzing features & OCR text...',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 64, color: AppColors.primary.withOpacity(0.6)),
                              const SizedBox(height: 16),
                              const Text('Select or Capture Image', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Camera'),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library),
                                    label: const Text('Gallery'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              if (_selectedImage != null)
                PrimaryButton(
                  text: 'Run Gemini AI Match',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: _isScanning,
                  onPressed: _runAiScan,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
