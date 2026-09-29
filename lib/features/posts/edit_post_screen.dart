import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/app_image.dart';
import '../../core/models/post_model.dart';
import '../../core/providers/providers.dart';
import '../../core/utils/post_delete_helper.dart';
import '../../core/utils/app_localizations.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _rewardController = TextEditingController();

  String _selectedCategory = 'Electronics';
  String _selectedType = 'lost';
  double _latitude = 23.8103;
  double _longitude = 90.4125;

  List<String> _existingImages = [];
  final List<XFile> _newPickedFiles = [];
  final List<Uint8List> _newPickedBytes = [];
  bool _isLoadingPost = true;
  bool _isSaving = false;
  String _statusMessage = '';
  PostModel? _post;

  static const List<String> _categories = [
    'Electronics',
    'Documents',
    'Wallet/Bags',
    'Keys',
    'Clothing',
    'Jewelry',
    'Pets',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    final firestoreService = ref.read(firestoreServiceProvider);
    final post = await firestoreService.getPost(widget.postId);
    final user = ref.read(currentUserProvider).value;

    if (!mounted) return;

    if (post == null) {
      setState(() => _isLoadingPost = false);
      return;
    }

    // Ownership check: User can only edit their own post
    if (user != null && post.userId != user.uid) {
      setState(() {
        _isLoadingPost = false;
        _post = null;
      });
      return;
    }

    _titleController.text = post.title;
    _descController.text = post.description;
    _locationController.text = post.location;
    _rewardController.text = post.rewardAmount > 0
        ? post.rewardAmount.toInt().toString()
        : '';

    setState(() {
      _post = post;
      _selectedCategory = _categories.contains(post.category)
          ? post.category
          : 'Other';
      _selectedType = post.type;
      _latitude = post.latitude;
      _longitude = post.longitude;
      _existingImages = List<String>.from(post.images);
      _isLoadingPost = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<void> _pickNewImages() async {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    final totalImages = _existingImages.length + _newPickedFiles.length;
    if (totalImages >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'প্রতি পোস্টে সর্বোচ্চ ৫টি ছবি দেওয়া যাবে।'
                : 'Maximum 5 images allowed per post.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final List<XFile> selected = await picker.pickMultiImage(
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 50,
      );

      if (selected.isNotEmpty) {
        final availableSlots = 5 - totalImages;
        final toAdd = selected.take(availableSlots).toList();

        for (final file in toAdd) {
          final bytes = await file.readAsBytes();
          if (mounted) {
            setState(() {
              _newPickedFiles.add(file);
              _newPickedBytes.add(bytes);
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn
                  ? 'ছবি নির্বাচন করা যায়নি: ${e.toString()}'
                  : 'Could not pick images: ${e.toString()}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewPickedImage(int index) {
    setState(() {
      _newPickedFiles.removeAt(index);
      _newPickedBytes.removeAt(index);
    });
  }

  Future<void> _savePostChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    final user = ref.read(currentUserProvider).value;
    if (user == null || _post == null || _post!.userId != user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isBn
                ? 'আপনি এই পোস্টটি সম্পাদনা করার অধিকারী নন।'
                : 'You are not authorized to edit this post.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _statusMessage = isBn ? 'আপডেটের প্রস্তুতি চলছে...' : 'Preparing updates...';
    });

    try {
      List<String> updatedImageUrls = List<String>.from(_existingImages);

      // 1. Upload newly selected images to Cloudinary
      if (_newPickedFiles.isNotEmpty) {
        setState(() {
          _statusMessage = isBn ? 'নতুন ছবি আপলোড হচ্ছে...' : 'Uploading new images...';
        });
        final cloudinaryService = ref.read(cloudinaryServiceProvider);
        final uploadedUrls = await cloudinaryService.uploadMultipleXFiles(
          _newPickedFiles,
          folder: 'posts',
        );
        updatedImageUrls.addAll(uploadedUrls);
      }

      // If all images removed, fallback placeholder
      if (updatedImageUrls.isEmpty) {
        updatedImageUrls.add(
          'https://picsum.photos/seed/${widget.postId}/600/400',
        );
      }

      // 2. Persist post update to Firestore & local store
      setState(() {
        _statusMessage = isBn ? 'পোস্ট সংরক্ষণ হচ্ছে...' : 'Saving post changes...';
      });

      final reward = double.tryParse(_rewardController.text.trim()) ?? 0.0;
      final firestoreService = ref.read(firestoreServiceProvider);

      await firestoreService.updatePost(
        postId: widget.postId,
        userId: user.uid,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        type: _selectedType,
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        rewardAmount: reward,
        images: updatedImageUrls,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBn ? 'পোস্ট সফলভাবে আপডেট করা হয়েছে!' : 'Post updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${isBn ? 'ব্যর্থ হয়েছে:' : 'Failed to update post:'} ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    if (_isLoadingPost) {
      return Scaffold(
        appBar: AppBar(title: Text(isBn ? 'পোস্ট সম্পাদনা' : 'Edit Post')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_post == null || (user != null && _post!.userId != user.uid)) {
      return Scaffold(
        appBar: AppBar(title: Text(isBn ? 'পোস্ট সম্পাদনা' : 'Edit Post')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                isBn ? 'প্রবেশাধিকার নেই' : 'Access Denied',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                isBn
                    ? 'আপনি এই পোস্টটি সম্পাদনা করার অধিকারী নন।'
                    : 'You are not authorized to edit this post.',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text(isBn ? 'ফিরে যান' : 'Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isBn ? 'পোস্ট সম্পাদনা' : 'Edit Post'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _isSaving ? null : () => context.pop(),
          ),
          actions: [
            if (_post != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                tooltip: isBn ? 'পোস্ট মুছুন' : 'Delete Post',
                onPressed: _isSaving
                    ? null
                    : () => PostDeleteHelper.confirmAndDeletePost(
                        context: context,
                        ref: ref,
                        post: _post!,
                        onSuccess: () => context.pop(),
                      ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post Type Selection
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Center(
                            child: Text(
                              isBn ? 'হারানো আইটেম' : 'LOST ITEM',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          selected: _selectedType == 'lost',
                          selectedColor: AppColors.error.withValues(alpha: 0.2),
                          onSelected: _isSaving
                              ? null
                              : (sel) {
                                  if (sel) {
                                    setState(() => _selectedType = 'lost');
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: Center(
                            child: Text(
                              isBn ? 'পাওয়া আইটেম' : 'FOUND ITEM',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          selected: _selectedType == 'found',
                          selectedColor: Colors.green.withValues(alpha: 0.2),
                          onSelected: _isSaving
                              ? null
                              : (sel) {
                                  if (sel) {
                                    setState(() => _selectedType = 'found');
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Form Fields Card
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        labelText: isBn ? 'আইটেমের শিরোনাম' : 'Item Title',
                        hintText: isBn ? 'যেমন: হারানো আইফোন ১৩ প্রো' : 'e.g. Lost iPhone 13 Pro',
                        prefixIcon: Icons.title_rounded,
                        enabled: !_isSaving,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return isBn ? 'শিরোনাম আবশ্যক' : 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: isBn ? 'বিভাগ' : 'Category',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(loc.translateCategory(cat)),
                          );
                        }).toList(),
                        onChanged: _isSaving
                            ? null
                            : (val) {
                                if (val != null) {
                                  setState(() => _selectedCategory = val);
                                }
                              },
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        controller: _locationController,
                        labelText: isBn ? 'অবস্থান / এলাকা' : 'Location / Area',
                        hintText: isBn ? 'যেমন: ধানমন্ডি ৩২, ঢাকা' : 'e.g. Dhanmondi 32, Dhaka',
                        prefixIcon: Icons.location_on_outlined,
                        enabled: !_isSaving,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return isBn ? 'অবস্থান আবশ্যক' : 'Location is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        controller: _rewardController,
                        labelText: isBn ? 'পুরস্কারের পরিমাণ (৳)' : 'Reward Amount (৳)',
                        hintText: isBn ? 'ঐচ্ছিক পুরস্কারের প্রস্তাব' : 'Optional reward offer',
                        prefixIcon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        enabled: !_isSaving,
                      ),
                      const SizedBox(height: 14),

                      CustomTextField(
                        controller: _descController,
                        labelText: isBn ? 'বিস্তারিত বিবরণ' : 'Detailed Description',
                        hintText: isBn
                            ? 'রং, চিহ্ন, হারানোর/পাওয়ার সময় উল্লেখ করুন...'
                            : 'Describe color, marks, time lost/found...',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 4,
                        enabled: !_isSaving,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return isBn ? 'বিবরণ আবশ্যক' : 'Description is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Images Section
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'পোস্টের ছবি' : 'Post Images',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${_existingImages.length + _newPickedFiles.length}/5',
                            style: const TextStyle(
                              color: AppColors.outline,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 90,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Existing Images
                            ...List.generate(_existingImages.length, (idx) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: AppImage(
                                        url: _existingImages[idx],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: _isSaving
                                            ? null
                                            : () => _removeExistingImage(idx),
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.black54,
                                          child: Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Newly Picked Local Images
                            ...List.generate(_newPickedFiles.length, (idx) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        _newPickedBytes[idx],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: _isSaving
                                            ? null
                                            : () => _removeNewPickedImage(idx),
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.black54,
                                          child: Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // Add Image Button
                            if (_existingImages.length +
                                    _newPickedFiles.length <
                                5)
                              InkWell(
                                onTap: _isSaving ? null : _pickNewImages,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_a_photo_outlined,
                                        color: AppColors.primary,
                                        size: 26,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isBn ? 'ছবি যোগ' : 'Add Photo',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_isSaving && _statusMessage.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _statusMessage,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                PrimaryButton(
                  text: isBn ? 'পরিবর্তন সংরক্ষণ করুন' : 'Save Post Changes',
                  icon: Icons.check_circle_outline,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _savePostChanges,
                ),
                if (_post != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () => PostDeleteHelper.confirmAndDeletePost(
                            context: context,
                            ref: ref,
                            post: _post!,
                            onSuccess: () => context.pop(),
                          ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(isBn ? 'পোস্ট মুছুন' : 'Delete Post'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
