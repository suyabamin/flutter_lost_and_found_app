class CampusModel {
  final String id;
  final String code;
  final String name;
  final String institutionName;
  final String description;
  final String location;
  final String address;
  final String logoUrl;
  final String creatorId;
  final String creatorName;
  final String status; // 'active', 'inactive'
  final DateTime createdAt;

  CampusModel({
    required this.id,
    required this.code,
    required this.name,
    required this.institutionName,
    this.description = '',
    this.location = 'Dhaka, Bangladesh',
    this.address = '',
    this.logoUrl = '',
    required this.creatorId,
    required this.creatorName,
    this.status = 'active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code.toUpperCase().trim(),
      'name': name,
      'institutionName': institutionName,
      'description': description,
      'location': location,
      'address': address,
      'logoUrl': logoUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CampusModel.fromMap(Map<String, dynamic> map, String docId) {
    return CampusModel(
      id: docId,
      code: (map['code'] ?? docId).toString().toUpperCase().trim(),
      name: map['name'] ?? '',
      institutionName: map['institutionName'] ?? map['name'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? 'Dhaka, Bangladesh',
      address: map['address'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? 'Campus Admin',
      status: map['status'] ?? 'active',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }
}

class CampusMemberModel {
  final String id; // `${campusId}_${uid}`
  final String uid;
  final String campusId;
  final String studentId;
  final String role; // 'student', 'author', 'campus_admin'
  final String status; // 'active', 'pending', 'suspended'
  final DateTime joinedAt;

  CampusMemberModel({
    required this.id,
    required this.uid,
    required this.campusId,
    required this.studentId,
    this.role = 'student',
    this.status = 'active',
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'campusId': campusId,
      'studentId': studentId,
      'role': role,
      'status': status,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory CampusMemberModel.fromMap(Map<String, dynamic> map, String docId) {
    return CampusMemberModel(
      id: docId,
      uid: map['uid'] ?? '',
      campusId: map['campusId'] ?? '',
      studentId: map['studentId'] ?? '',
      role: map['role'] ?? 'student',
      status: map['status'] ?? 'active',
      joinedAt: _parseDateTime(map['joinedAt']),
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
