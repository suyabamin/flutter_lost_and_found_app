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
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;

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
    DateTime? createdAt,
    this.approvedAt,
    this.rejectedAt,
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
      'claimDocuments': claimDocuments,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
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
      claimImages: List<String>.from(map['claimImages'] ?? []),
      claimDocuments: List<String>.from(map['claimDocuments'] ?? []),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      rejectedAt: map['rejectedAt'] != null ? DateTime.parse(map['rejectedAt']) : null,
      isClaimerSharingLocation: map['isClaimerSharingLocation'] ?? false,
      isOwnerSharingLocation: map['isOwnerSharingLocation'] ?? false,
      claimerLat: (map['claimerLat'] as num?)?.toDouble(),
      claimerLng: (map['claimerLng'] as num?)?.toDouble(),
      ownerLat: (map['ownerLat'] as num?)?.toDouble(),
      ownerLng: (map['ownerLng'] as num?)?.toDouble(),
    );
  }
}
