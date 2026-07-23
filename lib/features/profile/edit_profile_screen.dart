import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      _nameController.text = user.displayName;
      _phoneController.text = user.phoneNumber;
      _locationController.text = user.location;
    } else {
      _nameController.text = 'Tanvir Ahmed';
      _phoneController.text = '+8801700000000';
      _locationController.text = 'Dhanmondi, Dhaka';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=60'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 16,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _locationController,
                    labelText: 'Location / City',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            PrimaryButton(
              text: 'Save Changes',
              icon: Icons.check,
              isLoading: _isLoading,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
