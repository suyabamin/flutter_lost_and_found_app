import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class UniversityDashboardScreen extends ConsumerWidget {
  const UniversityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Lost & Found Portal'),
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
                  CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.school, color: Colors.white)),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dhaka University Campus Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('TSC & Central Library Lost Section', style: TextStyle(fontSize: 12, color: AppColors.outline)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Active Campus Logs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  Icon(Icons.badge, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Student ID Card (CSE Dept)', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Found at Curzon Hall Cafe', style: TextStyle(fontSize: 12, color: AppColors.outline)),
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
