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

class CreateLostPostStep1Screen extends ConsumerStatefulWidget {
  const CreateLostPostStep1Screen({super.key});

  @override
  ConsumerState<CreateLostPostStep1Screen> createState() => _CreateLostPostStep1ScreenState();
}

class _CreateLostPostStep1ScreenState extends ConsumerState<CreateLostPostStep1Screen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController(text: 'Dhanmondi, Dhaka');
  final _rewardController = TextEditingController(text: '1000');
  final _formKey = GlobalKey<FormState>();

  String _type = 'lost';
  String _category = 'Electronics';
  final List<XFile> _pickedXFiles = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        setState(() => _pickedXFiles.add(picked));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
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
      'rewardAmount': double.tryParse(_rewardController.text.trim()) ?? 0.0,
      'pickedFiles': _pickedXFiles,
    };

    context.push('/preview-report', extra: postData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
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
              const Text(
                'Report Lost or Found Item',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Step 1 of 2: Item Details & Photos', style: TextStyle(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 20),

              // Type Switcher
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('I Lost Something')),
                      selected: _type == 'lost',
                      selectedColor: AppColors.error,
                      labelStyle: TextStyle(color: _type == 'lost' ? Colors.white : null, fontWeight: FontWeight.bold),
                      onSelected: (val) => setState(() => _type = 'lost'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('I Found Something')),
                      selected: _type == 'found',
                      selectedColor: AppColors.secondary,
                      labelStyle: TextStyle(color: _type == 'found' ? Colors.white : null, fontWeight: FontWeight.bold),
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
                      labelText: 'Title',
                      hintText: 'e.g. Silver iPhone 14 Pro with blue case',
                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Electronics', 'Wallets', 'Documents', 'Keys', 'Pets', 'Clothing', 'Others']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _descController,
                      labelText: 'Description',
                      hintText: 'Provide detailed info (color, serial numbers, marks...)',
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Provide description' : null,
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _locationController,
                      labelText: 'Location',
                      hintText: 'e.g. Near Dhanmondi 27, Dhaka',
                      prefixIcon: Icons.location_on_outlined,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.map_rounded, color: AppColors.primary),
                        onPressed: () => context.push('/select-location'),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (_type == 'lost')
                      CustomTextField(
                        controller: _rewardController,
                        labelText: 'Reward Amount (BDT Optional)',
                        hintText: '1000',
                        prefixIcon: Icons.card_giftcard_rounded,
                        keyboardType: TextInputType.number,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Add Images (Up to 4)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),

              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pickedXFiles.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == _pickedXFiles.length) {
                      return InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 90,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: AppColors.primary),
                              SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      );
                    }

                    final xfile = _pickedXFiles[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: kIsWeb
                          ? Image.network(xfile.path, width: 90, height: 90, fit: BoxFit.cover)
                          : Image.file(File(xfile.path), width: 90, height: 90, fit: BoxFit.cover),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Preview & Publish Report',
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
