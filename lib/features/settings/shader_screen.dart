import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class ShaderScreen extends ConsumerStatefulWidget {
  const ShaderScreen({super.key});

  @override
  ConsumerState<ShaderScreen> createState() => _ShaderScreenState();
}

class _ShaderScreenState extends ConsumerState<ShaderScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Shader Background'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(AppColors.primary, AppColors.secondary, _controller.value)!,
                  Color.lerp(AppColors.tertiary, AppColors.primaryContainer, _controller.value)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Interactive Custom Shader / Dynamic Waves Demo',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
