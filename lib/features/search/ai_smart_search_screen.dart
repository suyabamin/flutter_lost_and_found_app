import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/primary_button.dart';

class AiSmartSearchScreen extends ConsumerStatefulWidget {
  const AiSmartSearchScreen({super.key});

  @override
  ConsumerState<AiSmartSearchScreen> createState() => _AiSmartSearchScreenState();
}

class _AiSmartSearchScreenState extends ConsumerState<AiSmartSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  double _radius = 5.0;
  double _minReward = 500.0;
  String _selectedCategory = 'Electronics';
  String _selectedDateRange = 'Last 7 Days';
  bool _isListening = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerVoiceSearch() {
    setState(() => _isListening = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isListening = false;
          _searchController.text = 'Black leather wallet lost near Dhanmondi Lake';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Smart Search'),
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
            const Text(
              'Smart AI Search',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Describe what you lost or use voice search for intelligent visual and text matching.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Search Bar & Mic
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Describe your lost item in natural language...',
                prefixIcon: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic_none_rounded : Icons.mic_rounded, color: AppColors.primary),
                  onPressed: _triggerVoiceSearch,
                ),
              ),
              maxLines: 2,
            ),
            if (_isListening) ...[
              const SizedBox(height: 8),
              Row(
                children: const [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Listening...', style: TextStyle(color: AppColors.primary, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // AI Filters Block
            const Text('AI Filtering Parameters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['Electronics', 'Documents', 'Wallets', 'Pets', 'Accessories', 'Others']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDateRange,
                    decoration: const InputDecoration(labelText: 'Time Window'),
                    items: ['Last 24 Hours', 'Last 7 Days', 'Last 30 Days', 'All Time']
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedDateRange = v!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Search Radius', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('${_radius.round()} km', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _radius,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _radius = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Minimum Reward (BDT)', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('৳ ${_minReward.round()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _minReward,
                    min: 0,
                    max: 10000,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _minReward = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            PrimaryButton(
              text: 'Run AI Smart Search',
              icon: Icons.auto_awesome_rounded,
              onPressed: () {
                final query = _searchController.text.trim();
                context.push('/search-results?query=$query&category=$_selectedCategory');
              },
            ),
          ],
        ),
      ),
    );
  }
}
