import 'dart:typed_data';
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
import '../../core/utils/app_localizations.dart';

class SubmitClaimScreen extends ConsumerStatefulWidget {
  final String postId;

  const SubmitClaimScreen({super.key, required this.postId});

  /// Easy-to-configure maximum proof image limit for claims
  static const int maxClaimImages = 5;

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
  final List<Uint8List> _pickedBytes = [];
  bool _isSubmitting = false;
  String _uploadStatusMessage = '';

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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImages() async {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    if (_pickedImages.length >= SubmitClaimScreen.maxClaimImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'সর্বোচ্চ ${SubmitClaimScreen.maxClaimImages}টি প্রমাণের ছবি দেওয়া যাবে।'
                : 'Maximum ${SubmitClaimScreen.maxClaimImages} proof images allowed.',
          ),
        ),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final List<XFile> selected = await picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (selected.isNotEmpty) {
        final availableSlots =
            SubmitClaimScreen.maxClaimImages - _pickedImages.length;
        final toAdd = selected.take(availableSlots).toList();

        for (final xfile in toAdd) {
          final bytes = await xfile.readAsBytes();
          if (mounted) {
            setState(() {
              _pickedImages.add(xfile);
              _pickedBytes.add(bytes);
            });
          }
        }

        if (selected.length > availableSlots && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isBn
                    ? '${SubmitClaimScreen.maxClaimImages}টি ছবির সীমার মধ্যে রাখতে কেবল প্রথম $availableSlotsটি ছবি যোগ করা হয়েছে।'
                    : 'Only the first $availableSlots images were added to stay within the ${SubmitClaimScreen.maxClaimImages}-image limit.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not pick images: $e')));
      }
    }
  }

  void _removeImage(int index) {
    if (index >= 0 && index < _pickedImages.length) {
      setState(() {
        _pickedImages.removeAt(index);
        if (index < _pickedBytes.length) {
          _pickedBytes.removeAt(index);
        }
      });
    }
  }

  Future<void> _handleSubmitClaim() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    final authUser = FirebaseAuth.instance.currentUser;
    final currentUid = authUser?.uid;

    if (currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'দাবি জমা দিতে আপনাকে সাইন ইন করতে হবে।'
                : 'You must be signed in to submit a claim.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadStatusMessage = isBn
          ? 'পোস্ট ও দাবি যাচাই করা হচ্ছে...'
          : 'Validating post & claim permissions...';
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final post = await firestoreService.getPost(widget.postId);

      if (post == null) {
        throw Exception(
          isBn ? 'মূল পোস্টটি পাওয়া যায়নি।' : 'Original post not found.',
        );
      }

      if (post.status == 'closed' || post.status == 'completed') {
        throw Exception(
          isBn ? 'এই পোস্টটি আর সক্রিয় নেই।' : 'This post is no longer active.',
        );
      }

      if (post.userId == currentUid) {
        throw Exception(
          isBn
              ? 'আপনি নিজের পোস্টে দাবি জমা দিতে পারবেন না।'
              : 'You cannot submit a claim for your own post.',
        );
      }

      // Pre-flight duplicate claim check
      final alreadyClaimed = await firestoreService.hasActiveClaim(
        currentUid,
        widget.postId,
      );
      if (alreadyClaimed) {
        throw Exception(
          isBn
              ? 'আপনি ইতিমধ্যে এই আইটেমের জন্য দাবি জমা দিয়েছেন।'
              : 'You have already submitted a claim for this item.',
        );
      }

      // Upload proof images to Cloudinary with controlled concurrency
      List<String> imageUrls = [];
      if (_pickedImages.isNotEmpty) {
        setState(() {
          _uploadStatusMessage = isBn
              ? 'ছবি আপলোডের প্রস্তুতি চলছে...'
              : 'Preparing image upload...';
        });

        final cloudinaryService = ref.read(cloudinaryServiceProvider);
        imageUrls = await cloudinaryService.uploadMultipleXFiles(
          _pickedImages,
          maxConcurrency: 3,
          onProgress: (completed, total, message) {
            if (mounted) {
              setState(() {
                _uploadStatusMessage = message;
              });
            }
          },
        );
      }

      setState(() {
        _uploadStatusMessage = isBn
            ? 'দাবির নথি সংরক্ষণ হচ্ছে...'
            : 'Saving claim document...';
      });

      final user = ref.read(currentUserProvider).value;
      final claimId = 'claim_${currentUid}_${widget.postId}';

      final newClaim = ClaimModel(
        claimId: claimId,
        postId: widget.postId,
        postOwnerId: post.userId,
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

      await firestoreService.createClaim(newClaim);

      if (_pickedBytes.isNotEmpty) {
        FirestoreService.storeLocalClaimImageBytes(
          claimId,
          List.from(_pickedBytes),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn
                  ? '🎉 দাবি সফলভাবে জমা দেওয়া হয়েছে! পোস্টের মালিককে বিজ্ঞপ্তি পাঠানো হয়েছে।'
                  : '🎉 Claim submitted successfully! Notification sent to owner.',
            ),
          ),
        );
        context.pushReplacement('/claim-details/$claimId');
      }
    } catch (e) {
      if (mounted) {
        final cleanMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $cleanMsg')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadStatusMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

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

    return PopScope(
      canPop: !_isSubmitting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isBn
                    ? 'আপলোড চলছে। অনুগ্রহ করে দাবি জমা শেষ হওয়া পর্যন্ত অপেক্ষা করুন।'
                    : 'Upload in progress. Please wait until claim submission completes.',
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isBn ? 'আইটেম দাবি করুন' : 'Claim Item'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _isSubmitting ? null : () => context.pop(),
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
                  isBn ? 'আইটেম দাবি জমা দিন' : 'Submit Item Claim',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isBn
                      ? 'আইটেমটি দাবি করতে মালিকানার বিবরণ বা প্রাপ্তির অবস্থান প্রদান করুন।'
                      : 'Provide ownership details or discovery location to claim this item.',
                  style: const TextStyle(
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
                        labelText: isBn ? 'পুরো নাম' : 'Full Name',
                        hintText: 'Tanvir Ahmed',
                        prefixIcon: Icons.person_outline,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? (isBn ? 'আপনার পুরো নাম লিখুন' : 'Enter your full name')
                            : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _phoneController,
                        labelText: isBn ? 'ফোন নম্বর' : 'Phone Number',
                        hintText: '+8801700000000',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? (isBn ? 'যোগাযোগের ফোন নম্বর দিন' : 'Enter contact phone')
                            : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _emailController,
                        labelText: isBn ? 'ইমেইল ঠিকানা' : 'Email Address',
                        hintText: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _addressController,
                        labelText: isBn ? 'বর্তমান ঠিকানা' : 'Current Address',
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
                        labelText: isBn ? 'দাবির বিবরণ' : 'Claim Description',
                        hintText: isBn
                            ? 'কখন ও কোথায় আপনি এটি হারিয়েছেন/পেয়েছেন তা ব্যাখ্যা করুন...'
                            : 'Explain when & where you lost/found this item...',
                        maxLines: 3,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? (isBn ? 'দাবির বিবরণ প্রদান করুন' : 'Provide claim description')
                            : null,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _proofController,
                        labelText: isBn
                            ? 'মালিকানার প্রমাণ / শনাক্তকারী চিহ্ন'
                            : 'Proof of Ownership / Identifiers',
                        hintText: isBn
                            ? 'সিরিয়াল নম্বর, অনন্য চিহ্ন, ওয়ালপেপারের ছবি...'
                            : 'Serial number, unique marks, wallpaper photo details...',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _rewardController,
                        labelText: isBn
                            ? 'পুরস্কারের প্রত্যাশা (ঐচ্ছিক টাকা)'
                            : 'Reward Expectation (BDT Optional)',
                        hintText: '0',
                        prefixIcon: Icons.card_giftcard_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'প্রমাণের ছবি আপলোড করুন' : 'Upload Proof Images',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_pickedImages.length}/${SubmitClaimScreen.maxClaimImages}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 105,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        _pickedImages.length < SubmitClaimScreen.maxClaimImages
                        ? _pickedImages.length + 1
                        : _pickedImages.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      if (index == _pickedImages.length &&
                          _pickedImages.length <
                              SubmitClaimScreen.maxClaimImages) {
                        return InkWell(
                          onTap: _isSubmitting ? null : _pickImages,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 95,
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
                                const Icon(
                                  Icons.add_a_photo_rounded,
                                  color: AppColors.primary,
                                  size: 26,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isBn ? 'ছবি যোগ' : 'Add Proof',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final xfile = _pickedImages[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AppImage(
                              url: xfile.path,
                              bytes: index < _pickedBytes.length
                                  ? _pickedBytes[index]
                                  : null,
                              width: 95,
                              height: 105,
                              fit: BoxFit.cover,
                              placeholderSeed: 'claim_$index',
                            ),
                          ),
                          if (!_isSubmitting)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                if (_isSubmitting && _uploadStatusMessage.isNotEmpty) ...[
                  GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _uploadStatusMessage,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                PrimaryButton(
                  text: _isSubmitting
                      ? (isBn ? 'দাবি জমা হচ্ছে...' : 'Submitting Claim...')
                      : (isBn ? 'মালিকের কাছে দাবি পাঠান' : 'Submit Claim to Owner'),
                  icon: Icons.send_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _handleSubmitClaim,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
