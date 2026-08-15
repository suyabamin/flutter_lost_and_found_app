import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../providers/location_dashboard_provider.dart';
import '../utils/location_utils.dart';

class RadiusSearchCard extends ConsumerWidget {
  const RadiusSearchCard({super.key});

  static const List<double> _quickChipsKm = [
    1.0,
    2.0,
    5.0,
    10.0,
    20.0,
    50.0,
    100.0,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radiusState = ref.watch(radiusSearchProvider);
    final radiusNotifier = ref.read(radiusSearchProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title & Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.radar_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Radius Search Filter',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        radiusState.isEnabled
                            ? 'Showing items within ${LocationUtils.formatDistance(radiusState.radiusKm)}'
                            : 'Radius filter disabled (All distances)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: radiusState.isEnabled,
                activeColor: AppColors.primary,
                onChanged: (val) => radiusNotifier.toggleEnabled(val),
              ),
            ],
          ),

          if (radiusState.isEnabled) ...[
            const SizedBox(height: 16),

            // Quick Selection Chips
            const Text(
              'Quick Distance Preset',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickChipsKm.map((km) {
                  final bool isSelected =
                      (radiusState.radiusKm - km).abs() < 0.1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        km < 1.0
                            ? '${(km * 1000).toInt()} m'
                            : '${km.toInt()} KM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : AppColors.onSurface),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          radiusNotifier.setRadius(km);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // Custom Radius Slider (500m to 100 KM)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Custom Radius:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    LocationUtils.formatDistance(radiusState.radiusKm),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.15),
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
              ),
              child: Slider(
                value: radiusState.radiusKm.clamp(0.5, 100.0),
                min: 0.5,
                max: 100.0,
                divisions: 199, // Allows ~500m increments
                label: LocationUtils.formatDistance(radiusState.radiusKm),
                onChanged: (val) {
                  radiusNotifier.setRadius(val);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '500 m',
                    style: TextStyle(fontSize: 10, color: AppColors.outline),
                  ),
                  Text(
                    '50 KM',
                    style: TextStyle(fontSize: 10, color: AppColors.outline),
                  ),
                  Text(
                    '100 KM',
                    style: TextStyle(fontSize: 10, color: AppColors.outline),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // Secondary Filters (Type & Sorting)
            const Text(
              'Filter & Sort Options',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Post Type Chips: All, Lost, Found
                _buildFilterBadge(
                  label: 'All Items',
                  isSelected: radiusState.filterType == null,
                  onTap: () => radiusNotifier.setFilterType(null),
                  isDark: isDark,
                ),
                _buildFilterBadge(
                  label: 'Lost Only 🔴',
                  isSelected: radiusState.filterType == 'lost',
                  onTap: () => radiusNotifier.setFilterType('lost'),
                  isDark: isDark,
                ),
                _buildFilterBadge(
                  label: 'Found Only 🟢',
                  isSelected: radiusState.filterType == 'found',
                  onTap: () => radiusNotifier.setFilterType('found'),
                  isDark: isDark,
                ),
                // Sorting Chips: Nearest, Newest, Reward, AI Match
                _buildSortChip(
                  label: 'Nearest 📍',
                  optionName: 'Nearest',
                  currentSort: radiusState.sortOption,
                  onTap: () => radiusNotifier.setSortOption('Nearest'),
                  isDark: isDark,
                ),
                _buildSortChip(
                  label: 'Newest ⏱️',
                  optionName: 'Newest',
                  currentSort: radiusState.sortOption,
                  onTap: () => radiusNotifier.setSortOption('Newest'),
                  isDark: isDark,
                ),
                _buildSortChip(
                  label: 'Reward 💰',
                  optionName: 'Reward',
                  currentSort: radiusState.sortOption,
                  onTap: () => radiusNotifier.setSortOption('Reward'),
                  isDark: isDark,
                ),
                _buildSortChip(
                  label: 'AI Match ✨',
                  optionName: 'AI Match',
                  currentSort: radiusState.sortOption,
                  onTap: () => radiusNotifier.setSortOption('AI Match'),
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBadge({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary
              : (isDark ? AppColors.darkSurface : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip({
    required String label,
    required String optionName,
    required String currentSort,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final bool isSelected = currentSort == optionName;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.onSurface),
          ),
        ),
      ),
    );
  }
}
