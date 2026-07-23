import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class OfficeDashboardScreen extends ConsumerWidget {
  const OfficeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corporate Office Portal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  CircleAvatar(backgroundColor: AppColors.secondary, child: Icon(Icons.corporate_fare, color: Colors.white)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gulshan Hub Security Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Building 4, Level 1 Reception', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Unclaimed Visitors Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  Icon(Icons.laptop_chromebook, color: AppColors.secondary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dell USB-C Charger', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Found in Conference Room B', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
