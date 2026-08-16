import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle: pending → reviewing → resolved | rejected
class ReportModel {
  final String reportId; // deterministic: '${reporterId}_${postId}'
  final String postId;
  final String reporterId;
  final String reporterName;
  final String reason;
  final String description;
  final String status; // 'pending', 'reviewing', 'resolved', 'rejected'
  final String postTitle; // snapshot for admin view
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reviewedAt;
  final String reviewedBy; // admin UID, empty if not yet reviewed

  const ReportModel({
    required this.reportId,
    required this.postId,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    this.description = '',
    this.status = 'pending',
    this.postTitle = '',
    required this.createdAt,
    required this.updatedAt,
    this.reviewedAt,
    this.reviewedBy = '',
  });

  /// Supported report reason categories.
  static const List<String> reasons = [
    'Spam',
    'Fake Post',
    'Inappropriate Content',
    'Fraud/Scam',
    'Wrong Information',
    'Duplicate Post',
    'Other',
  ];

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'postId': postId,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'reason': reason,
      'description': description,
      'status': status,
      'postTitle': postTitle,
      // Use server timestamp for authoritative creation time
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
      'reviewedBy': reviewedBy,
    };
  }

  /// Map used when updating status (admin moderation). Does NOT overwrite
  /// createdAt; only touches status, updatedAt, reviewedAt, reviewedBy.
  Map<String, dynamic> toStatusUpdateMap({
    required String newStatus,
    required String adminUid,
  }) {
    return {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminUid,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReportModel(
      reportId: docId,
      postId: map['postId'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? 'Anonymous',
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      postTitle: map['postTitle'] ?? '',
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
      reviewedAt: map['reviewedAt'] != null
          ? _parseTimestamp(map['reviewedAt'])
          : null,
      reviewedBy: map['reviewedBy'] ?? '',
    );
  }

  ReportModel copyWith({
    String? status,
    DateTime? updatedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return ReportModel(
      reportId: reportId,
      postId: postId,
      reporterId: reporterId,
      reporterName: reporterName,
      reason: reason,
      description: description,
      status: status ?? this.status,
      postTitle: postTitle,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}

DateTime _parseTimestamp(dynamic val) {
  if (val == null) return DateTime.now();
  if (val is Timestamp) return val.toDate();
  if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
  if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
  try {
    return (val as dynamic).toDate();
  } catch (_) {
    return DateTime.now();
  }
}
