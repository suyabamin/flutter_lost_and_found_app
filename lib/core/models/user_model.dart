class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phoneNumber;
  final String role; // 'user', 'admin', 'university', 'office'
  final bool isNidVerified;
  final int rewardPoints;
  final String location;
  final double averageRating;
  final int totalReviews;
  final int completedRecoveries;
  final int completedReturns;
  final int trustScore;
  final int successfulRecoveryCount;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.phoneNumber = '',
    this.role = 'user',
    this.isNidVerified = false,
    this.rewardPoints = 0,
    this.location = 'Dhaka, Bangladesh',
    this.averageRating = 5.0,
    this.totalReviews = 0,
    this.completedRecoveries = 0,
    this.completedReturns = 0,
    this.trustScore = 100,
    this.successfulRecoveryCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'role': role,
      'isNidVerified': isNidVerified,
      'rewardPoints': rewardPoints,
      'location': location,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'totalRatings': totalReviews,
      'completedRecoveries': completedRecoveries,
      'completedReturns': completedReturns,
      'trustScore': trustScore,
      'successfulRecoveryCount': successfulRecoveryCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Anonymous User',
      photoUrl: map['photoUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? 'user',
      isNidVerified: map['isNidVerified'] ?? false,
      rewardPoints: map['rewardPoints'] ?? 0,
      location: map['location'] ?? 'Dhaka, Bangladesh',
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 5.0,
      totalReviews:
          (map['totalReviews'] as num?)?.toInt() ??
          (map['totalRatings'] as num?)?.toInt() ??
          0,
      completedRecoveries: (map['completedRecoveries'] as num?)?.toInt() ?? 0,
      completedReturns: (map['completedReturns'] as num?)?.toInt() ?? 0,
      trustScore: (map['trustScore'] as num?)?.toInt() ?? 100,
      successfulRecoveryCount:
          (map['successfulRecoveryCount'] as num?)?.toInt() ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }
}

DateTime _parseDateTime(dynamic val) {
  if (val == null) return DateTime.now();
  if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
  if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
  try {
    return (val as dynamic).toDate();
  } catch (_) {
    return DateTime.now();
  }
}
