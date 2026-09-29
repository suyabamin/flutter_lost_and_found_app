import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/app_image.dart';
import '../../core/models/post_model.dart';
import '../../core/models/claim_model.dart';
import '../../core/providers/providers.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/post_delete_helper.dart';
import '../../core/utils/app_localizations.dart';
import 'report_post_sheet.dart';

class ItemDetailsScreen extends ConsumerWidget {
  final String id;

  const ItemDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestoreService = ref.watch(firestoreServiceProvider);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      body: FutureBuilder<PostModel?>(
        future: firestoreService.getPost(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = snapshot.data;

          final String title = post?.title ?? (l10n.isBangla ? 'রিপোর্টকৃত আইটেম' : 'Reported Lost/Found Item');
          final String description =
              post?.description ?? (l10n.isBangla ? 'রিপোর্টকৃত আইটেমের বিস্তারিত বিবরণ।' : 'Detailed description of the reported item.');
          final String category = post?.category ?? 'Electronics';
          final String type = post?.type ?? 'lost';
          final String location = post?.location ?? 'Dhaka, Bangladesh';
          final String userName = post?.userName.isNotEmpty == true
              ? post!.userName
              : (l10n.isBangla ? 'যাচাইকৃত কমিউনিটি সদস্য' : 'Verified Community Member');
          final double rewardAmount = post?.rewardAmount ?? 0.0;
          final String mainImage = (post?.images.isNotEmpty == true)
              ? post!.images.first
              : 'https://picsum.photos/seed/$id/600/400';
          final isLost = type == 'lost';

          return StreamBuilder<List<ClaimModel>>(
            stream: firestoreService.streamClaimsForPost(id),
            builder: (context, claimsSnapshot) {
              final claims = claimsSnapshot.data ?? [];
              final authUser = FirebaseAuth.instance.currentUser;
              final currentUid = user?.uid ?? authUser?.uid;

              final bool isPostOwner =
                  (currentUid != null &&
                  post != null &&
                  currentUid == post.userId);
              final bool hasApprovedClaim = claims.any(
                (c) => c.claimerId == currentUid && c.status == 'approved',
              );
              final existingUserClaim = claims
                  .where(
                    (c) => c.claimerId == currentUid && c.status != 'rejected',
                  )
                  .firstOrNull;
              final bool hasPendingOrApprovedClaim = existingUserClaim != null;

              // Poster can never claim, and user cannot claim twice
              final bool canClaim =
                  !isPostOwner &&
                  (post?.status != 'closed' && post?.status != 'completed') &&
                  !hasPendingOrApprovedClaim;

              // Only show messaging if user is post owner OR claim has been approved
              final bool showMessaging = isPostOwner || hasApprovedClaim;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    leading: CircleAvatar(
                      backgroundColor: isDark ? Colors.black54 : Colors.white70,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    actions: [
                      if (isPostOwner) ...[
                        CircleAvatar(
                          backgroundColor: isDark
                              ? Colors.black54
                              : Colors.white70,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.primary,
                            ),
                            tooltip: l10n.t('edit_post'),
                            onPressed: () =>
                                context.push('/edit-post/${post.id}'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: isDark
                              ? Colors.black54
                              : Colors.white70,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                            ),
                            tooltip: l10n.t('delete_post'),
                            onPressed: () =>
                                PostDeleteHelper.confirmAndDeletePost(
                                  context: context,
                                  ref: ref,
                                  post: post,
                                  onSuccess: () => context.pop(),
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      CircleAvatar(
                        backgroundColor: isDark
                            ? Colors.black54
                            : Colors.white70,
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border_rounded),
                          onPressed: () => context.push('/favorites'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: isDark
                            ? Colors.black54
                            : Colors.white70,
                        child: IconButton(
                          icon: const Icon(Icons.share_rounded),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.isBangla
                                      ? 'আইটেমের লিংক ক্লিপবোর্ডে কপি করা হয়েছে!'
                                      : 'Item link copied to clipboard!',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: AppImage(
                        url: mainImage,
                        bytes: FirestoreService.getLocalImageBytes(
                          id,
                        )?.firstOrNull,
                        fit: BoxFit.cover,
                        placeholderSeed: id,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isLost
                                      ? AppColors.error
                                      : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isLost
                                      ? (l10n.isBangla ? 'হারানো আইটেম' : 'LOST ITEM')
                                      : (l10n.isBangla ? 'পাওয়া আইটেম' : 'FOUND ITEM'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                post?.date.isNotEmpty == true
                                    ? (l10n.isBangla ? 'রিপোর্টকৃত ${post!.date}' : 'Reported ${post!.date}')
                                    : (l10n.isBangla ? 'সম্প্রতি রিপোর্টকৃত' : 'Recently Reported'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.t('category')}: ${l10n.translateCategory(category)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Reward Highlight (If available)
                          if (rewardAmount > 0) ...[
                            GlassContainer(
                              borderRadius: 16,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.military_tech_rounded,
                                        color: Colors.amber,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.isBangla ? 'পুরস্কার ঘোষিত' : 'Reward Offered',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '৳ ${rewardAmount.round()}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          Text(
                            l10n.t('description'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Reporter Info Card
                          GlassContainer(
                            borderRadius: 20,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/100?img=12',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.isBangla ? '$userName কর্তৃক রিপোর্টকৃত' : 'Reported by $userName',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.isBangla
                                            ? 'এনআইডি যাচাইকৃত সদস্য • $location'
                                            : 'NID Verified Member • $location',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.verified_user_rounded,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Claim This Item Primary Action Button (Always shown for active items)
                          if (canClaim) ...[
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 54),
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 4,
                              ),
                              onPressed: () => context.push(
                                '/submit-claim/${post?.id ?? id}',
                              ),
                              icon: const Icon(
                                Icons.assignment_turned_in_rounded,
                                size: 22,
                              ),
                              label: Text(
                                l10n.isBangla ? 'আইটেমটি দাবি করুন' : 'Claim This Item',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ] else if (!isPostOwner &&
                              existingUserClaim != null) ...[
                            GlassContainer(
                              borderRadius: 20,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      l10n.isBangla
                                          ? 'আপনি ইতিমধ্যে এই আইটেমের জন্য দাবি জমা দিয়েছেন।'
                                          : 'You have already submitted a claim for this item.',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push(
                                      '/claim-details/${existingUserClaim.claimId}',
                                    ),
                                    child: Text(l10n.isBangla ? 'অবস্থা দেখুন' : 'View Status'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Secondary Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () =>
                                      context.push('/google-map-view'),
                                  icon: const Icon(Icons.map_outlined),
                                  label: Text(l10n.isBangla ? 'ম্যাপে দেখুন' : 'View on Map'),
                                ),
                              ),
                              if (showMessaging) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PrimaryButton(
                                    text: l10n.isBangla ? 'চ্যাট ও যোগাযোগ' : 'Chat & Contact',
                                    icon: Icons.chat_rounded,
                                    onPressed: () async {
                                      // Find approved chat room or open chats page
                                      context.push('/chats');
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Report Post
                          if (!isPostOwner && currentUid != null) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: Semantics(
                                label: l10n.isBangla ? 'এই পোস্ট রিপোর্ট করুন' : 'Report this post',
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                    foregroundColor: AppColors.error,
                                    side: const BorderSide(
                                      color: AppColors.error,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () => showReportPostSheet(
                                    context,
                                    postId: post?.id ?? id,
                                    postTitle: title,
                                  ),
                                  icon: const Icon(
                                    Icons.flag_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    l10n.isBangla ? 'পোস্ট রিপোর্ট করুন' : 'Report Post',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
