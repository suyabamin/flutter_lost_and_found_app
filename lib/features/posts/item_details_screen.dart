import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/models/post_model.dart';
import '../../core/models/claim_model.dart';
import '../../core/providers/providers.dart';

class ItemDetailsScreen extends ConsumerWidget {
  final String id;

  const ItemDetailsScreen({super.key, required this.id});

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
          final String description = post?.description ?? 'Detailed description of the reported item.';
          final String category = post?.category ?? 'Electronics';
          final String type = post?.type ?? 'lost';
          final String location = post?.location ?? 'Dhaka, Bangladesh';
          final String userName = post?.userName.isNotEmpty == true ? post!.userName : 'Verified Community Member';
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

              final bool isPostOwner = (currentUid != null && post != null && currentUid == post.userId);
              final bool hasApprovedClaim = claims.any((c) => c.claimerId == currentUid && c.status == 'approved');
              final bool hasPendingOrApprovedClaim = claims.any((c) => c.claimerId == currentUid);

              // Poster can never claim, and user cannot claim twice
              final bool canClaim = !isPostOwner && (post?.status != 'closed') && !hasPendingOrApprovedClaim;

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
                      CircleAvatar(
                        backgroundColor: isDark ? Colors.black54 : Colors.white70,
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border_rounded),
                          onPressed: () => context.push('/favorites'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: isDark ? Colors.black54 : Colors.white70,
                        child: IconButton(
                          icon: const Icon(Icons.share_rounded),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Item link copied to clipboard!')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: mainImage.startsWith('data:image') || mainImage.startsWith('http')
                          ? Image.network(
                              mainImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.network('https://picsum.photos/seed/$id/600/400', fit: BoxFit.cover),
                            )
                          : Image.network('https://picsum.photos/seed/$id/600/400', fit: BoxFit.cover),
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isLost ? AppColors.error : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isLost ? 'LOST ITEM' : 'FOUND ITEM',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              Text(
                                post?.date.isNotEmpty == true ? 'Reported ${post!.date}' : 'Recently Reported',
                                style: const TextStyle(fontSize: 12, color: AppColors.outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Text(
                            title,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Category: $category',
                            style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.military_tech_rounded, color: Colors.amber, size: 28),
                                      SizedBox(width: 8),
                                      Text('Reward Offered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    ],
                                  ),
                                  Text(
                                    '৳ ${rewardAmount.round()}',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5),
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
                                  backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Reported by $userName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text('NID Verified Member • $location', style: const TextStyle(fontSize: 12, color: AppColors.outline)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.verified_user_rounded, color: AppColors.primary),
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 4,
                              ),
                              onPressed: () => context.push('/submit-claim/${post?.id ?? id}'),
                              icon: const Icon(Icons.assignment_turned_in_rounded, size: 22),
                              label: const Text(
                                'Claim This Item',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  onPressed: () => context.push('/google-map-view'),
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
