class ClaimModel {
  final String claimId;
  final String postId;
  final String postOwnerId;
  final String claimerId;
  final String claimerName;
  final String claimerPhone;
  final String claimerEmail;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final String proofDescription;
  final double rewardRequested;
  final List<String> claimImages;
  final List<String> claimDocuments;
  final String status; // 'pending', 'approved', 'rejected', 'completed'
  final String recoveryStatus; // 'in_progress', 'both_confirmed'
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? ownerConfirmedAt;
  final DateTime? finderConfirmedAt;

  // Live Location tracking parameters (optional)
  final bool isClaimerSharingLocation;
  final bool isOwnerSharingLocation;
  final double? claimerLat;
  final double? claimerLng;
  final double? ownerLat;
  final double? ownerLng;

  ClaimModel({
    required this.claimId,
    required this.postId,
    required this.postOwnerId,
    required this.claimerId,
    required this.claimerName,
    required this.claimerPhone,
    required this.claimerEmail,
    required this.address,
    this.latitude = 23.8103,
    this.longitude = 90.4125,
    required this.description,
    this.proofDescription = '',
    this.rewardRequested = 0.0,
    required this.claimImages,
    this.claimDocuments = const [],
    this.status = 'pending',
    this.recoveryStatus = 'in_progress',
    DateTime? createdAt,
    this.approvedAt,
    this.rejectedAt,
    this.ownerConfirmedAt,
    this.finderConfirmedAt,
    this.isClaimerSharingLocation = false,
    this.isOwnerSharingLocation = false,
    this.claimerLat,
    this.claimerLng,
    this.ownerLat,
    this.ownerLng,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'claimId': claimId,
      'postId': postId,
      'postOwnerId': postOwnerId,
      'claimerId': claimerId,
      'claimerName': claimerName,
      'claimerPhone': claimerPhone,
      'claimerEmail': claimerEmail,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'proofDescription': proofDescription,
      'rewardRequested': rewardRequested,
      'claimImages': claimImages,
      'imageUrls': claimImages,
      'claimDocuments': claimDocuments,
      'status': status,
      'recoveryStatus': recoveryStatus,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
      'ownerConfirmedAt': ownerConfirmedAt?.toIso8601String(),
      'finderConfirmedAt': finderConfirmedAt?.toIso8601String(),
      'isClaimerSharingLocation': isClaimerSharingLocation,
      'isOwnerSharingLocation': isOwnerSharingLocation,
      'claimerLat': claimerLat,
      'claimerLng': claimerLng,
      'ownerLat': ownerLat,
      'ownerLng': ownerLng,
    };
  }

  factory ClaimModel.fromMap(Map<String, dynamic> map, String id) {
    return ClaimModel(
      claimId: id,
      postId: map['postId'] ?? '',
      postOwnerId: map['postOwnerId'] ?? '',
      claimerId: map['claimerId'] ?? '',
      claimerName: map['claimerName'] ?? 'Anonymous Claimer',
      claimerPhone: map['claimerPhone'] ?? '',
      claimerEmail: map['claimerEmail'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 90.4125,
      description: map['description'] ?? '',
      proofDescription: map['proofDescription'] ?? '',
      rewardRequested: (map['rewardRequested'] as num?)?.toDouble() ?? 0.0,
      claimImages: List<String>.from(
        map['claimImages'] ?? map['imageUrls'] ?? [],
      ),
      claimDocuments: List<String>.from(map['claimDocuments'] ?? []),
      status: map['status'] ?? 'pending',
      recoveryStatus: map['recoveryStatus'] ?? 'in_progress',
      createdAt: _parseDateTime(map['createdAt']),
      approvedAt: _parseNullableDateTime(map['approvedAt']),
      rejectedAt: _parseNullableDateTime(map['rejectedAt']),
      ownerConfirmedAt: _parseNullableDateTime(map['ownerConfirmedAt']),
      finderConfirmedAt: _parseNullableDateTime(map['finderConfirmedAt']),
      isClaimerSharingLocation: map['isClaimerSharingLocation'] ?? false,
      isOwnerSharingLocation: map['isOwnerSharingLocation'] ?? false,
      claimerLat: (map['claimerLat'] as num?)?.toDouble(),
      claimerLng: (map['claimerLng'] as num?)?.toDouble(),
      ownerLat: (map['ownerLat'] as num?)?.toDouble(),
      ownerLng: (map['ownerLng'] as num?)?.toDouble(),
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

DateTime? _parseNullableDateTime(dynamic val) {
  if (val == null) return null;
  if (val is String) return DateTime.tryParse(val);
  if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
  try {
    return (val as dynamic).toDate();
  } catch (_) {
    return null;
  }
}
