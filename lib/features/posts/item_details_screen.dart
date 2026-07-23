import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';

class ItemDetailsScreen extends ConsumerWidget {
  final String id;

  const ItemDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
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
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                'https://picsum.photos/seed/$id/600/400',
                fit: BoxFit.cover,
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('LOST ITEM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const Text('Reported 3 hours ago', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Silver iPhone 14 Pro (128GB)',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                      SizedBox(width: 4),
                      Text('Banani Road 11, Dhaka', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Reward Highlight
                  GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.military_tech_rounded, color: Colors.amber, size: 28),
                            SizedBox(width: 8),
                            Text('Reward Offered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        Text('৳ 2,500', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                    'Lost near the coffee shop on Banani Road 11 around 4:00 PM. The phone is in a dark blue transparent case. Has a small visible scratch near the camera module.',
                    style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5),
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
                            children: const [
                              Text('Reported by Naimur Rahman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              SizedBox(height: 2),
                              Text('NID Verified Member • Dhanmondi', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified_user_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () => context.push('/google-map-view'),
                          icon: const Icon(Icons.map_outlined),
                          label: const Text('View on Map'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Chat & Claim',
                          icon: Icons.chat_rounded,
                          onPressed: () => context.push('/chat/$id'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
