import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/report_model.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _statuses = [
    'All',
    'pending',
    'reviewing',
    'resolved',
    'rejected',
  ];
  static const _tabLabels = [
    'All',
    'Pending',
    'Reviewing',
    'Resolved',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    // Guard: admin-only screen
    if (currentUser == null) {
      return _buildAccessDenied('Please sign in to access this page.');
    }
    if (currentUser.role != 'admin') {
      return _buildAccessDenied(
        'This section is restricted to administrators.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Moderation'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses
            .map((status) => _ReportTab(status: status, adminUser: currentUser))
            .toList(),
      ),
    );
  }

  Widget _buildAccessDenied(String msg) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Moderation')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: AppColors.outline,
            ),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single tab of reports
// ─────────────────────────────────────────────────────────────────────────────

class _ReportTab extends ConsumerWidget {
  final String status;
  final UserModel adminUser;

  const _ReportTab({required this.status, required this.adminUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsByStatusProvider(status));

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _EmptyState(
        icon: Icons.error_outline_rounded,
        message: 'Unable to load reports. Please try again.',
        iconColor: AppColors.error,
      ),
      data: (reports) {
        if (reports.isEmpty) {
          return _EmptyState(
            icon: Icons.check_circle_outline_rounded,
            message: status == 'All'
                ? 'No reports have been filed yet.'
                : 'No ${status == 'All' ? '' : status} reports.',
            iconColor: AppColors.secondary,
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) =>
              _ReportCard(report: reports[i], adminUid: adminUser.uid),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report card
// ─────────────────────────────────────────────────────────────────────────────

class _ReportCard extends ConsumerStatefulWidget {
  final ReportModel report;
  final String adminUid;

  const _ReportCard({required this.report, required this.adminUid});

  @override
  ConsumerState<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<_ReportCard> {
  bool _isUpdating = false;

  Future<void> _changeStatus(String newStatus) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .updateReportStatus(
            reportId: widget.report.reportId,
            newStatus: newStatus,
            adminUid: widget.adminUid,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: ${_friendlyError(e.toString())}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.toLowerCase().contains('permission')) return 'Permission denied.';
    if (raw.toLowerCase().contains('network') ||
        raw.toLowerCase().contains('unavailable')) {
      return 'Network error. Please check your connection.';
    }
    return 'Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final statusColor = _statusColor(report.status);

    return GlassContainer(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.postTitle.isNotEmpty
                          ? '"${report.postTitle}"'
                          : 'Post ID: ${report.postId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reported by ${report.reporterName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _statusLabel(report.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Reason ──────────────────────────────────────────────────
          _InfoChip(
            icon: Icons.flag_outlined,
            label: report.reason,
            color: AppColors.error,
          ),

          // ── Description ─────────────────────────────────────────────
          if (report.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              report.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 10),

          // ── Timestamp ───────────────────────────────────────────────
          Text(
            _formatDate(report.createdAt),
            style: const TextStyle(fontSize: 11, color: AppColors.outline),
          ),

          // ── Moderation actions ───────────────────────────────────────
          if (report.status == 'pending' || report.status == 'reviewing') ...[
            const Divider(height: 20),
            Row(
              children: [
                if (report.status == 'pending')
                  _ActionButton(
                    label: 'Mark Reviewing',
                    icon: Icons.visibility_outlined,
                    color: AppColors.primary,
                    isLoading: _isUpdating,
                    onTap: () => _changeStatus('reviewing'),
                  ),
                if (report.status == 'pending') const SizedBox(width: 8),
                _ActionButton(
                  label: 'Resolve',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.secondary,
                  isLoading: _isUpdating,
                  onTap: () => _changeStatus('resolved'),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Reject',
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                  isLoading: _isUpdating,
                  onTap: () => _changeStatus('rejected'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewing':
        return AppColors.primary;
      case 'resolved':
        return AppColors.secondary;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'PENDING';
      case 'reviewing':
        return 'REVIEWING';
      case 'resolved':
        return 'RESOLVED';
      case 'rejected':
        return 'REJECTED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small helper widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isLoading ? null : onTap,
        icon: isLoading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: color, strokeWidth: 2),
              )
            : Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color iconColor;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: iconColor.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}
