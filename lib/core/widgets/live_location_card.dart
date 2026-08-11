import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../providers/location_dashboard_provider.dart';
import '../utils/location_utils.dart';

class LiveLocationCard extends ConsumerWidget {
  const LiveLocationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveState = ref.watch(liveLocationProvider);
    final liveNotifier = ref.read(liveLocationProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String lastUpdatedStr = liveState.lastUpdated != null
        ? DateFormat('hh:mm:ss a').format(liveState.lastUpdated!)
        : 'Not yet updated';

    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getStatusColor(liveState).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(liveState),
                  color: _getStatusColor(liveState),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Location Dashboard',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(liveState),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusLabel(liveState),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(liveState),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                tooltip: 'Refresh Current Location',
                onPressed: () => liveNotifier.refreshCurrentLocation(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Privacy Assurance Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Private: Live location is only visible to you on your dashboard.',
                    style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Location Details Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      icon: Icons.my_location_rounded,
                      label: 'Coordinates',
                      value: LocationUtils.formatCoordinates(liveState.latitude, liveState.longitude),
                    ),
                    _buildInfoColumn(
                      icon: Icons.gps_fixed_rounded,
                      label: 'GPS Accuracy',
                      value: LocationUtils.formatAccuracy(liveState.accuracy),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                      icon: Icons.map_rounded,
                      label: 'Latitude / Longitude',
                      value: '${liveState.latitude.toStringAsFixed(4)}, ${liveState.longitude.toStringAsFixed(4)}',
                    ),
                    _buildInfoColumn(
                      icon: Icons.access_time_rounded,
                      label: 'Last Updated',
                      value: lastUpdatedStr,
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (liveState.errorMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      liveState.errorMessage!,
                      style: const TextStyle(fontSize: 11, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Tracking Control Action Buttons
          Row(
            children: [
              // ENABLE LIVE LOCATION
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: liveState.trackingStatus == LiveTrackingStatus.active
                        ? AppColors.primary
                        : AppColors.primaryContainer,
                    foregroundColor: liveState.trackingStatus == LiveTrackingStatus.active
                        ? Colors.white
                        : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (!liveState.isGpsEnabled) {
                      _showEnableGpsDialog(context, liveNotifier);
                    } else if (!liveState.hasPermission) {
                      _showPermissionDialog(context, liveNotifier);
                    } else {
                      await liveNotifier.enableLiveLocation();
                    }
                  },
                  icon: Icon(
                    liveState.trackingStatus == LiveTrackingStatus.active
                        ? Icons.sensors_rounded
                        : Icons.play_arrow_rounded,
                    size: 18,
                  ),
                  label: Text(
                    liveState.trackingStatus == LiveTrackingStatus.active ? 'Live Active' : 'Enable Live',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // PAUSE LIVE LOCATION
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: liveState.trackingStatus == LiveTrackingStatus.paused
                        ? Colors.orange
                        : AppColors.outline,
                    side: BorderSide(
                      color: liveState.trackingStatus == LiveTrackingStatus.paused
                          ? Colors.orange
                          : AppColors.outlineVariant,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: liveState.trackingStatus == LiveTrackingStatus.active
                      ? () => liveNotifier.pauseLiveLocation()
                      : null,
                  icon: const Icon(Icons.pause_rounded, size: 18),
                  label: const Text(
                    'Pause',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // STOP LIVE LOCATION
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  foregroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                tooltip: 'Stop Live Tracking',
                onPressed: liveState.trackingStatus != LiveTrackingStatus.stopped
                    ? () => liveNotifier.stopLiveLocation()
                    : null,
                icon: const Icon(Icons.stop_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppColors.outline, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(LiveLocationState state) {
    if (!state.isGpsEnabled || !state.hasPermission) return AppColors.error;
    switch (state.trackingStatus) {
      case LiveTrackingStatus.active:
        return Colors.green;
      case LiveTrackingStatus.paused:
        return Colors.orange;
      case LiveTrackingStatus.stopped:
        return AppColors.outline;
    }
  }

  IconData _getStatusIcon(LiveLocationState state) {
    if (!state.isGpsEnabled) return Icons.location_off_rounded;
    if (!state.hasPermission) return Icons.lock_outline_rounded;
    switch (state.trackingStatus) {
      case LiveTrackingStatus.active:
        return Icons.sensors_rounded;
      case LiveTrackingStatus.paused:
        return Icons.pause_circle_outline_rounded;
      case LiveTrackingStatus.stopped:
        return Icons.location_on_outlined;
    }
  }

  String _getStatusLabel(LiveLocationState state) {
    if (!state.isGpsEnabled) return 'GPS Disabled';
    if (!state.hasPermission) return 'Permission Denied';
    switch (state.trackingStatus) {
      case LiveTrackingStatus.active:
        return 'Live Location Active';
      case LiveTrackingStatus.paused:
        return 'Live Tracking Paused';
      case LiveTrackingStatus.stopped:
        return 'Live Tracking Off';
    }
  }

  void _showPermissionDialog(BuildContext context, LiveLocationNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_searching_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Location Permission'),
          ],
        ),
        content: const Text(
          'Lost & Found Bangladesh requires GPS location access to find nearby lost items and display your radius on the map.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(context);
              await notifier.checkGpsAndPermissions();
              await notifier.enableLiveLocation();
            },
            child: const Text('Grant Access', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEnableGpsDialog(BuildContext context, LiveLocationNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gps_off_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('GPS Disabled'),
          ],
        ),
        content: const Text(
          'Device GPS location services are currently turned off. Please turn on Location/GPS in settings to enable live search.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
              await notifier.checkGpsAndPermissions();
            },
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
