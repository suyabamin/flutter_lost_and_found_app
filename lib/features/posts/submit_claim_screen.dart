import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/app_image.dart';
import '../../core/models/claim_model.dart';
import '../../core/providers/providers.dart';
import '../../core/services/firestore_service.dart';

class SubmitClaimScreen extends ConsumerStatefulWidget {
  final String postId;

  const SubmitClaimScreen({super.key, required this.postId});

  @override
  ConsumerState<SubmitClaimScreen> createState() => _SubmitClaimScreenState();
}

class _SubmitClaimScreenState extends ConsumerState<SubmitClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController(text: 'Dhanmondi, Dhaka');
  final _descController = TextEditingController();
  final _proofController = TextEditingController();
  final _rewardController = TextEditingController(text: '0');

  double _latitude = 23.8103;
  double _longitude = 90.4125;
  final List<XFile> _pickedImages = [];
  final List<Uint8List> _pickedBytes = []; // raw bytes for local display
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentGpsLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _descController.dispose();
    _proofController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentGpsLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (_) {}
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
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedImages.add(picked);
          _pickedBytes.add(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
      }
    }
  }

  Future<void> _handleSubmitClaim() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    try {
      // Use FirebaseAuth directly (synchronous) — avoids the async StreamProvider
      // null bug where claimerId becomes 'claimer_timestamp' instead of real uid,
      // causing the Firestore read rule to deny access right after creation.
      final authUser = FirebaseAuth.instance.currentUser;
      final currentUid = authUser?.uid;

      if (currentUid == null) {
        throw Exception('You must be signed in to submit a claim.');
      }

      // Also read the Riverpod user for display name / email fallbacks
      final user = ref.read(currentUserProvider).value;
      final post = await ref
          .read(firestoreServiceProvider)
          .getPost(widget.postId);

      if (post == null) {
        throw Exception('Original post not found.');
      }

      // Upload proof images if provided
      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      List<String> imageUrls = [];
      if (_pickedImages.isNotEmpty) {
        imageUrls = await cloudinaryService.uploadMultipleXFiles(_pickedImages);
      }
      // Empty list is fine — claim images are optional proof documents

      final claimId = 'claim_${DateTime.now().millisecondsSinceEpoch}';
      final newClaim = ClaimModel(
        claimId: claimId,
        postId: widget.postId,
        postOwnerId: post.userId,
        // Always use the real Firebase Auth UID — never a guest/timestamp fallback
        claimerId: currentUid,
        claimerName: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : (user?.displayName ?? authUser?.displayName ?? 'Anonymous'),
        claimerPhone: _phoneController.text.trim(),
        claimerEmail: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : (user?.email ?? authUser?.email ?? ''),
        address: _addressController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        description: _descController.text.trim(),
        proofDescription: _proofController.text.trim(),
        rewardRequested: double.tryParse(_rewardController.text.trim()) ?? 0.0,
        claimImages: imageUrls,
        status: 'pending',
      );

      await ref.read(firestoreServiceProvider).createClaim(newClaim);

      // Store bytes so claim details screen can show the actual photo immediately
      if (_pickedBytes.isNotEmpty) {
        FirestoreService.storeLocalClaimImageBytes(
          claimId,
          List.from(_pickedBytes),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Claim submitted successfully! Notification sent to owner.',
            ),
          ),
        );
        context.push('/claim-details/$claimId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting claim: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    if (_nameController.text.isEmpty && user?.displayName != null) {
      _nameController.text = user!.displayName;
    }
    if (_emailController.text.isEmpty && user?.email != null) {
      _emailController.text = user!.email;
    }
    if (_phoneController.text.isEmpty && user?.phoneNumber != null) {
      _phoneController.text = user!.phoneNumber;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Item'),
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
                'Submit Item Claim',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Provide ownership details or discovery location to claim this item.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              GlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'Tanvir Ahmed',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter your full name'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      hintText: '+8801700000000',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter contact phone'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      hintText: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _addressController,
                      labelText: 'Current Address',
                      hintText: 'Dhanmondi, Dhaka',
                      prefixIcon: Icons.location_on_outlined,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.my_location_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: _fetchCurrentGpsLocation,
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _descController,
                      labelText: 'Claim Description',
                      hintText:
                          'Explain when & where you lost/found this item...',
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Provide claim description'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _proofController,
                      labelText: 'Proof of Ownership / Identifiers',
                      hintText:
                          'Serial number, unique marks, wallpaper photo details...',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _rewardController,
                      labelText: 'Reward Expectation (BDT Optional)',
                      hintText: '0',
                      prefixIcon: Icons.card_giftcard_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Upload Proof Images & Documents',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pickedImages.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == _pickedImages.length) {
                      return InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 90,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: AppColors.primary),
                              SizedBox(height: 4),
                              Text(
                                'Add Proof',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final xfile = _pickedImages[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AppImage(
                        url: xfile.path,
                        bytes: index < _pickedBytes.length
                            ? _pickedBytes[index]
                            : null,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholderSeed: 'claim_$index',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Submit Claim to Owner',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _handleSubmitClaim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
