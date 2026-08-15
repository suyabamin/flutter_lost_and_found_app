import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home_dashboard/home_dashboard_screen.dart';

class HomeDashboardAnimatedScreen extends ConsumerStatefulWidget {
  const HomeDashboardAnimatedScreen({super.key});

  @override
  ConsumerState<HomeDashboardAnimatedScreen> createState() =>
      _HomeDashboardAnimatedScreenState();
}

class _HomeDashboardAnimatedScreenState
    extends ConsumerState<HomeDashboardAnimatedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: const HomeDashboardScreen(),
      ),
    );
  }
}
