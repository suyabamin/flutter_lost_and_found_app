class PostModel {
  final String id;
  final String title;
  final String description;
  final String category; // Electronics, Documents, Wallet, Keys, Clothing, Pets, Other
  final String type; // 'lost' or 'found'
  final String location;
  final double latitude;
  final double longitude;
  final String date;
  final List<String> images;
  final String userId;
  final String userName;
  final String userAvatar;
  final String status; // 'active', 'resolved', 'closed'
  final double rewardAmount;
  final double similarityScore;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.location,
    this.latitude = 23.8103,
    this.longitude = 90.4125,
    required this.date,
    required this.images,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    this.status = 'active',
    this.rewardAmount = 0.0,
    this.similarityScore = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'date': date,
      'images': images,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'status': status,
      'rewardAmount': rewardAmount,
      'similarityScore': similarityScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map, String docId) {
    return PostModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      type: map['type'] ?? 'lost',
      location: map['location'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 90.4125,
      date: map['date'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userAvatar: map['userAvatar'] ?? '',
      status: map['status'] ?? 'active',
      rewardAmount: (map['rewardAmount'] as num?)?.toDouble() ?? 0.0,
      similarityScore: (map['similarityScore'] as num?)?.toDouble() ?? 0.0,
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
