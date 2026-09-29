import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/utils/app_localizations.dart';

class CreateLostPostStep1Screen extends ConsumerStatefulWidget {
  const CreateLostPostStep1Screen({super.key});

  @override
  ConsumerState<CreateLostPostStep1Screen> createState() =>
      _CreateLostPostStep1ScreenState();
}

class _CreateLostPostStep1ScreenState
    extends ConsumerState<CreateLostPostStep1Screen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController(text: 'Dhanmondi, Dhaka');
  final _formKey = GlobalKey<FormState>();

  String _type = 'lost';
  String _category = 'Electronics';
  double? _latitude;
  double? _longitude;
  final List<XFile> _pickedXFiles = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final currentLoc = _locationController.text.trim();
    final result = await context.push<dynamic>(
      '/select-location?initial=${Uri.encodeComponent(currentLoc)}',
    );

    if (result != null) {
      if (result is Map) {
        setState(() {
          _locationController.text = result['address']?.toString() ?? '';
          _latitude = (result['lat'] as num?)?.toDouble();
          _longitude = (result['lng'] as num?)?.toDouble();
        });
      } else if (result is String && result.isNotEmpty) {
        setState(() {
          _locationController.text = result;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 50,
      );
      if (picked != null) {
        setState(() => _pickedXFiles.add(picked));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
      }
    }
  }

  void _proceedToPreview() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final postData = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'category': _category,
      'type': _type,
      'location': _locationController.text.trim(),
      'latitude': _latitude ?? 23.7461,
      'longitude': _longitude ?? 90.3742,
      'rewardAmount': 0.0,
      'pickedFiles': _pickedXFiles,
    };

    context.push('/preview-report', extra: postData);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('create_report')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('report_lost_or_found'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.t('step_1_of_2'),
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // Type Switcher
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text(l10n.t('i_lost_something'))),
                      selected: _type == 'lost',
                      selectedColor: AppColors.error,
                      labelStyle: TextStyle(
                        color: _type == 'lost' ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) => setState(() => _type = 'lost'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: Center(child: Text(l10n.t('i_found_something'))),
                      selected: _type == 'found',
                      selectedColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: _type == 'found' ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) => setState(() => _type = 'found'),
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
                      controller: _titleController,
                      labelText: l10n.t('title'),
                      hintText: l10n.t('title_hint'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? l10n.t('enter_title')
                          : null,
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: InputDecoration(labelText: l10n.t('category')),
                      items:
                          [
                                'Electronics',
                                'Wallets',
                                'Documents',
                                'Keys',
                                'Pets',
                                'Clothing',
                                'Others',
                              ]
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(l10n.translateCategory(c))),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _descController,
                      labelText: l10n.t('description'),
                      hintText: l10n.t('description_hint'),
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? (l10n.isBangla ? 'বিবরণ দিন' : 'Provide description')
                          : null,
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _locationController,
                      labelText: l10n.t('location'),
                      hintText: l10n.isBangla ? 'উদা: ধানমন্ডি ২৭ এর কাছে, ঢাকা' : 'e.g. Near Dhanmondi 27, Dhaka',
                      prefixIcon: Icons.location_on_outlined,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.map_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: _openLocationPicker,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _openLocationPicker,
                        icon: const Icon(Icons.pin_drop_rounded, size: 16),
                        label: Text(
                          l10n.isBangla ? 'ম্যাপে স্থান নির্বাচন / এলাকা খুঁজুন' : 'Pick Spot on Live Map / Search Place',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n.isBangla ? 'ছবি যোগ করুন (সর্বোচ্চ ৪টি)' : 'Add Images (Up to 4)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pickedXFiles.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == _pickedXFiles.length) {
                      return InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 90,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo, color: AppColors.primary),
                              const SizedBox(height: 4),
                              Text(
                                l10n.t('add_photos'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final xfile = _pickedXFiles[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: kIsWeb
                          ? Image.network(
                              xfile.path,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(xfile.path),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: l10n.isBangla ? 'প্রিভিউ এবং রিপোর্ট প্রকাশ করুন' : 'Preview & Publish Report',
                icon: Icons.arrow_forward_rounded,
                onPressed: _proceedToPreview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
