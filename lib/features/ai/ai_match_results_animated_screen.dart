import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_match_results_screen.dart';

class AiMatchResultsAnimatedScreen extends ConsumerStatefulWidget {
  const AiMatchResultsAnimatedScreen({super.key});

  @override
  ConsumerState<AiMatchResultsAnimatedScreen> createState() => _AiMatchResultsAnimatedScreenState();
}

class _AiMatchResultsAnimatedScreenState extends ConsumerState<AiMatchResultsAnimatedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: const AiMatchResultsScreen(),
      ),
    );
  }
}
