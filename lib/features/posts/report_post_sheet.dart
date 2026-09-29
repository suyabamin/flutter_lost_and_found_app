import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/report_model.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/utils/app_localizations.dart';

/// Shows the Report Post bottom-sheet.
///
/// Call via:
/// ```dart
/// showReportPostSheet(context, postId: post.id, postTitle: post.title);
/// ```
Future<void> showReportPostSheet(
  BuildContext context, {
  required String postId,
  required String postTitle,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _ReportPostSheet(postId: postId, postTitle: postTitle),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal stateful widget
// ─────────────────────────────────────────────────────────────────────────────

class _ReportPostSheet extends ConsumerStatefulWidget {
  final String postId;
  final String postTitle;

  const _ReportPostSheet({required this.postId, required this.postTitle});

  @override
  ConsumerState<_ReportPostSheet> createState() => _ReportPostSheetState();
}

class _ReportPostSheetState extends ConsumerState<_ReportPostSheet> {
  String? _selectedReason;
  final TextEditingController _descController = TextEditingController();
  String? _validationError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  String _translateReason(String reason, bool isBn) {
    if (!isBn) return reason;
    switch (reason) {
      case 'Spam or Misleading':
        return 'স্প্যাম বা বিভ্রান্তিকর';
      case 'Inappropriate Content':
        return 'অনুপযুক্ত বিষয়বস্তু';
      case 'Harassment or Hate Speech':
        return 'হয়রানি বা বিদ্বেষমূলক বক্তব্য';
      case 'False or Fraudulent Claim':
        return 'মিথ্যা বা প্রতারণামূলক দাবি';
      case 'Duplicate Post':
        return 'ডুপ্লিকেট পোস্ট';
      case 'Other':
        return 'অন্যান্য';
      default:
        return reason;
    }
  }

  // ── Submission ──────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    // Prevent double-tap / rapid multiple taps
    if (_isSubmitting) return;

    // Validation: reason must be selected
    if (_selectedReason == null || _selectedReason!.isEmpty) {
      setState(
        () => _validationError = isBn
            ? 'রিপোর্ট করার জন্য একটি কারণ নির্বাচন করুন।'
            : 'Please select a reason for reporting.',
      );
      return;
    }

    // Validate description length
    final description = _descController.text.trim();
    if (description.length > 500) {
      setState(
        () => _validationError = isBn
            ? 'বিবরণ সর্বোচ্চ ৫০০ অক্ষরের হতে হবে।'
            : 'Description must be 500 characters or fewer.',
      );
      return;
    }

    // Authentication check
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      setState(
        () => _validationError = isBn
            ? 'পোস্ট রিপোর্ট করতে আপনাকে সাইন ইন করতে হবে।'
            : 'You must be signed in to report a post.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _validationError = null;
    });

    final firestoreService = ref.read(firestoreServiceProvider);
    final currentUser = ref.read(currentUserProvider).value;
    final reporterName = currentUser?.displayName.isNotEmpty == true
        ? currentUser!.displayName
        : (authUser.displayName ?? 'Anonymous');

    // Duplicate check (pre-flight; server rules also protect)
    try {
      final alreadyReported = await firestoreService.hasUserReportedPost(
        authUser.uid,
        widget.postId,
      );
      if (alreadyReported) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _validationError = null;
        });
        _showResult(
          context,
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.primary,
          title: isBn ? 'ইতিমধ্যে রিপোর্ট করা হয়েছে' : 'Already Reported',
          message: isBn
              ? 'আপনি ইতিমধ্যে এই পোস্টটি রিপোর্ট করেছেন। আমাদের টিম শীঘ্রই এটি পর্যালোচনা করবে।'
              : 'You have already reported this post. Our team will review it shortly.',
          isSuccess: false,
        );
        return;
      }
    } catch (_) {
      // Fail-open: proceed to submit; server rules handle real duplicates
    }

    final report = ReportModel(
      reportId: '${authUser.uid}_${widget.postId}',
      postId: widget.postId,
      reporterId: authUser.uid,
      reporterName: reporterName,
      reason: _selectedReason!,
      description: description,
      postTitle: widget.postTitle,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await firestoreService.submitReport(report);

      if (!mounted) return;
      // Close the bottom sheet first
      Navigator.of(context).pop();

      // Show success feedback on the page behind
      if (mounted) {
        _showResult(
          // ignore: use_build_context_synchronously
          context,
          icon: Icons.check_circle_rounded,
          iconColor: Colors.green,
          title: isBn ? 'রিপোর্ট জমা হয়েছে' : 'Report Submitted',
          message: isBn
              ? 'ধন্যবাদ। আপনার রিপোর্ট পাওয়া গেছে এবং আমাদের টিম পর্যালোচনা করবে।'
              : 'Thank you. Your report has been received and will be reviewed by our team.',
          isSuccess: true,
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      String msg;
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('already-exists') ||
          errStr.contains('permission-denied')) {
        msg = isBn
            ? 'আপনি ইতিমধ্যে এই পোস্টটি রিপোর্ট করেছেন।'
            : 'You have already reported this post.';
      } else if (errStr.contains('unavailable') ||
          errStr.contains('network') ||
          errStr.contains('timeout')) {
        msg = isBn
            ? 'ইন্টারনেট সংযোগ নেই। নেটওয়ার্ক পরীক্ষা করে পুনরায় চেষ্টা করুন।'
            : 'No internet connection. Please check your network and try again.';
      } else if (errStr.contains('unauthenticated')) {
        msg = isBn
            ? 'পোস্ট রিপোর্ট করতে আপনাকে সাইন ইন করতে হবে।'
            : 'You must be signed in to report a post.';
      } else {
        msg = isBn
            ? 'রিপোর্ট জমা দিতে ব্যর্থ হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'
            : 'Unable to submit report. Please try again.';
      }

      setState(() => _validationError = msg);
    }
  }

  // ── Build UI ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final loc = AppLocalizations.of(context);
    final isBn = loc.isBangla;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'পোস্ট রিপোর্ট করুন' : 'Report Post',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isBn
                            ? 'কমিউনিটি নিরাপদ রাখতে আমাদের সাহায্য করুন।'
                            : 'Help us keep the community safe.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  label: isBn ? 'রিপোর্ট ডায়ালগ বন্ধ করুন' : 'Close report dialog',
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // ── Reason selection ─────────────────────────────────────
            Text(
              isBn ? 'একটি কারণ নির্বাচন করুন *' : 'Select a reason *',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 10),

            GlassContainer(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: ReportModel.reasons.map((reason) {
                  final isSelected = _selectedReason == reason;
                  final displayReason = _translateReason(reason, isBn);
                  return Semantics(
                    label: displayReason,
                    selected: isSelected,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() {
                        _selectedReason = reason;
                        _validationError = null;
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppColors.error
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.error
                                      : AppColors.outlineVariant,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                displayReason,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected ? AppColors.error : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ── Description ──────────────────────────────────────────
            Text(
              isBn ? 'অতিরিক্ত বিবরণ (ঐচ্ছিক)' : 'Additional details (optional)',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              maxLength: 500,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: isBn
                    ? 'সমস্যাটি সংক্ষেপে লিখুন যাতে আমাদের টিম দ্রুত পর্যালোচনা করতে পারে...'
                    : 'Describe the issue to help our team review faster...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.outline,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onChanged: (_) {
                if (_validationError != null) {
                  setState(() => _validationError = null);
                }
              },
            ),

            // ── Validation error ─────────────────────────────────────
            if (_validationError != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _validationError!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // ── Submit button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.error.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isSubmitting
                      ? (isBn ? 'জমা হচ্ছে…' : 'Submitting…')
                      : (isBn ? 'রিপোর্ট জমা দিন' : 'Submit Report'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ── Privacy note ─────────────────────────────────────────
            const SizedBox(height: 12),
            Center(
              child: Text(
                isBn
                    ? 'আপনার রিপোর্ট গোপনীয়। আমরা আপনার পরিচয় প্রকাশ করব না।'
                    : 'Your report is confidential. We will not share your identity.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppColors.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Result feedback helper — shown on the parent page after sheet closes
// ─────────────────────────────────────────────────────────────────────────────

void _showResult(
  BuildContext context, {
  required IconData icon,
  required Color iconColor,
  required String title,
  required String message,
  required bool isSuccess,
}) {
  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 48),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.outline),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess
                    ? AppColors.secondary
                    : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    ),
  );
}
