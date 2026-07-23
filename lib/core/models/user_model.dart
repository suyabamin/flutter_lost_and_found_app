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
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
