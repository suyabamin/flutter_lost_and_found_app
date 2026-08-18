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
import 'report_post_sheet.dart';

class ItemDetailsScreen extends ConsumerWidget {
  final String id;

  const ItemDetailsScreen({super.key, required this.id});

  Future<void> _confirmAndDeletePost(
    BuildContext context,
    WidgetRef ref,
    PostModel post,
    String currentUserId,
  ) async {
    final firestoreService = ref.read(firestoreServiceProvider);

    // 1. Safety check: Check if post has an active approved claim
    try {
      final claims = await firestoreService.streamClaimsForPost(post.id).first;
      final hasApprovedClaim = claims.any((c) => c.status == 'approved');
      if (hasApprovedClaim) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Cannot Delete Post'),
              content: const Text(
                'This post has an active approved claim or recovery in progress. Please complete or resolve the recovery process first.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
    } catch (_) {}

    // 2. Show confirmation dialog
    if (!context.mounted) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post?'),
        content: Text(
          'Are you sure you want to delete "${post.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await firestoreService.deletePost(
          postId: post.id,
          userId: currentUserId,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete post: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          final String title = post?.title ?? 'Reported Lost/Found Item';
          final String description =
              post?.description ?? 'Detailed description of the reported item.';
          final String category = post?.category ?? 'Electronics';
          final String type = post?.type ?? 'lost';
          final String location = post?.location ?? 'Dhaka, Bangladesh';
          final String userName = post?.userName.isNotEmpty == true
              ? post!.userName
              : 'Verified Community Member';
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
                            tooltip: 'Edit Post',
                            onPressed: () =>
                                context.push('/edit-post/${post?.id}'),
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
                            tooltip: 'Delete Post',
                            onPressed: () => _confirmAndDeletePost(
                              context,
                              ref,
                              post,
                              currentUid,
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
                              const SnackBar(
                                content: Text('Item link copied to clipboard!'),
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
                                  isLost ? 'LOST ITEM' : 'FOUND ITEM',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                post?.date.isNotEmpty == true
                                    ? 'Reported ${post!.date}'
                                    : 'Recently Reported',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.outline,
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
                            'Category: $category',
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
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.military_tech_rounded,
                                        color: Colors.amber,
                                        size: 28,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Reward Offered',
                                        style: TextStyle(
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

                          const Text(
                            'Description',
                            style: TextStyle(
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
                                        'Reported by $userName',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'NID Verified Member • $location',
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
                              label: const Text(
                                'Claim This Item',
                                style: TextStyle(
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
                                  const Expanded(
                                    child: Text(
                                      'You have already submitted a claim for this item.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push(
                                      '/claim-details/${existingUserClaim.claimId}',
                                    ),
                                    child: const Text('View Status'),
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
                                  label: const Text('View on Map'),
                                ),
                              ),
                              if (showMessaging) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PrimaryButton(
                                    text: 'Chat & Contact',
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

                          // Report Post — only shown to authenticated non-owners
                          if (!isPostOwner && currentUid != null) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: Semantics(
                                label: 'Report this post',
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
                                  label: const Text(
                                    'Report Post',
                                    style: TextStyle(
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
