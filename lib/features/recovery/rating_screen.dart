import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/models/claim_model.dart';
import '../../core/models/recovery_models.dart';
import '../../core/providers/providers.dart';

class RatingScreen extends ConsumerStatefulWidget {
  final String claimId;

  const RatingScreen({super.key, required this.claimId});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  final _reviewController = TextEditingController();

  double _overallRating = 5.0;
  double _behaviorRating = 5.0;
  double _communicationRating = 5.0;
  double _trustRating = 5.0;
  double _responseRating = 5.0;
  bool _recommendation = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating(ClaimModel claim) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final authUser = FirebaseAuth.instance.currentUser;
      final currentUid = authUser?.uid ?? 'guest';

      final isOwner = currentUid == claim.postOwnerId;
      final toUserId = isOwner ? claim.claimerId : claim.postOwnerId;

      final ratingId = 'rate_${widget.claimId}_$currentUid';

      final rating = RatingModel(
        ratingId: ratingId,
        postId: claim.postId,
        claimId: widget.claimId,
        fromUser: currentUid,
        toUser: toUserId,
        rating: _overallRating,
        review: _reviewController.text.trim(),
        behavior: _behaviorRating,
        communication: _communicationRating,
        trustworthiness: _trustRating,
        responseTime: _responseRating,
        recommendation: _recommendation,
        createdAt: DateTime.now(),
      );

      await firestoreService.createRating(rating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🌟 Thank you! Your rating & review have been submitted.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting rating: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate & Write Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<ClaimModel?>(
        stream: firestoreService.streamClaim(widget.claimId),
        builder: (context, snapshot) {
          final claim = snapshot.data;
          if (claim == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'How was your experience?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your rating builds community trust and safety.',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Overall Star Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      iconSize: 42,
                      icon: Icon(
                        starIndex <= _overallRating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => _overallRating = starIndex.toDouble()),
                    );
                  }),
                ),
                Text(
                  '${_overallRating.toInt()} / 5 Stars',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                const SizedBox(height: 24),

                // Detailed Aspect Ratings
                GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Detailed Experience Ratings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 14),

                      _buildAspectSlider('Behaviour', _behaviorRating, (val) => setState(() => _behaviorRating = val)),
                      _buildAspectSlider('Communication', _communicationRating, (val) => setState(() => _communicationRating = val)),
                      _buildAspectSlider('Trustworthiness', _trustRating, (val) => setState(() => _trustRating = val)),
                      _buildAspectSlider('Response Time', _responseRating, (val) => setState(() => _responseRating = val)),

                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Would you recommend this user?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Switch(
                            value: _recommendation,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => _recommendation = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Review Comment Field
                CustomTextField(
                  controller: _reviewController,
                  labelText: 'Write Review (Optional Comment)',
                  hintText: 'Share details about the return process, punctuality, and trust...',
                  maxLines: 4,
                  prefixIcon: Icons.rate_review_outlined,
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => context.pop(),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        text: 'Submit Rating',
                        icon: Icons.send_rounded,
                        isLoading: _isSubmitting,
                        onPressed: () => _submitRating(claim),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAspectSlider(String title, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${value.toInt()} / 5', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primary,
            ),
            child: Slider(
              value: value,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
