import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassContainer(
            borderRadius: 18,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Successfully Returned Item', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('Handed over Wallet to Tanvir • Earned +100 PTS', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                    ],
                  ),
                ),
                Text('Yesterday', style: TextStyle(fontSize: 11, color: AppColors.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
