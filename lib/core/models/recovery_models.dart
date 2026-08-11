class RatingModel {
  final String ratingId;
  final String postId;
  final String claimId;
  final String fromUser;
  final String toUser;
  final String fromUserId;
  final String toUserId;
  final double rating;
  final String review;
  final double behavior;
  final double communication;
  final double trustworthiness;
  final double responseTime;
  final bool recommendation;
  final DateTime createdAt;

  RatingModel({
    required this.ratingId,
    required this.postId,
    required this.claimId,
    required this.fromUser,
    required this.toUser,
    String? fromUserId,
    String? toUserId,
    required this.rating,
    this.review = '',
    this.behavior = 5.0,
    this.communication = 5.0,
    this.trustworthiness = 5.0,
    this.responseTime = 5.0,
    this.recommendation = true,
    DateTime? createdAt,
  })  : fromUserId = fromUserId ?? fromUser,
        toUserId = toUserId ?? toUser,
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'ratingId': ratingId,
      'postId': postId,
      'claimId': claimId,
      'fromUser': fromUser,
      'toUser': toUser,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'rating': rating,
      'review': review,
      'behavior': behavior,
      'communication': communication,
      'trustworthiness': trustworthiness,
      'responseTime': responseTime,
      'recommendation': recommendation,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map, String id) {
    final fUser = map['fromUserId'] ?? map['fromUser'] ?? '';
    final tUser = map['toUserId'] ?? map['toUser'] ?? '';
    return RatingModel(
      ratingId: id,
      postId: map['postId'] ?? '',
      claimId: map['claimId'] ?? '',
      fromUser: fUser,
      toUser: tUser,
      fromUserId: fUser,
      toUserId: tUser,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      review: map['review'] ?? '',
      behavior: (map['behavior'] as num?)?.toDouble() ?? 5.0,
      communication: (map['communication'] as num?)?.toDouble() ?? 5.0,
      trustworthiness: (map['trustworthiness'] as num?)?.toDouble() ?? 5.0,
      responseTime: (map['responseTime'] as num?)?.toDouble() ?? 5.0,
      recommendation: map['recommendation'] ?? true,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }
}

class PaymentModel {
  final String paymentId;
  final String postId;
  final String claimId;
  final String posterId;
  final String finderId;
  final String method; // 'bKash', 'Rocket', 'Nagad'
  final double amount;
  final String receiverName;
  final String receiverNumber;
  final String transactionId;
  final String status; // 'pending', 'paid', 'cancelled', 'failed', 'completed'
  final DateTime paidAt;
  final DateTime? confirmedAt;

  PaymentModel({
    required this.paymentId,
    required this.postId,
    required this.claimId,
    required this.posterId,
    required this.finderId,
    required this.method,
    required this.amount,
    required this.receiverName,
    required this.receiverNumber,
    required this.transactionId,
    this.status = 'paid',
    DateTime? paidAt,
    this.confirmedAt,
  }) : paidAt = paidAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'paymentId': paymentId,
      'postId': postId,
      'claimId': claimId,
      'posterId': posterId,
      'finderId': finderId,
      'method': method,
      'amount': amount,
      'receiverName': receiverName,
      'receiverNumber': receiverNumber,
      'transactionId': transactionId,
      'status': status,
      'paidAt': paidAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      paymentId: id,
      postId: map['postId'] ?? '',
      claimId: map['claimId'] ?? '',
      posterId: map['posterId'] ?? '',
      finderId: map['finderId'] ?? '',
      method: map['method'] ?? 'bKash',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      receiverName: map['receiverName'] ?? '',
      receiverNumber: map['receiverNumber'] ?? '',
      transactionId: map['transactionId'] ?? '',
      status: map['status'] ?? 'paid',
      paidAt: _parseDateTime(map['paidAt']),
      confirmedAt: _parseNullableDateTime(map['confirmedAt']),
    );
  }
}

class HistoryModel {
  final String historyId;
  final String originalPostId;
  final String claimId;
  final String posterId;
  final String finderId;
  final String ownerName;
  final String finderName;
  final double ownerRating;
  final double finderRating;
  final String ownerReview;
  final String finderReview;
  final String status;
  final String title;
  final String category;
  final String location;
  final double rewardAmount;
  final String paymentStatus;
  final double averageRating;
  final List<String> images;
  final DateTime completedDate;

  String get postId => originalPostId;
  String get ownerId => posterId;
  DateTime get completedAt => completedDate;

  HistoryModel({
    required this.historyId,
    required this.originalPostId,
    required this.claimId,
    required this.posterId,
    required this.finderId,
    this.ownerName = 'Item Owner',
    this.finderName = 'Finder',
    this.ownerRating = 5.0,
    this.finderRating = 5.0,
    this.ownerReview = '',
    this.finderReview = '',
    this.status = 'completed',
    required this.title,
    required this.category,
    required this.location,
    required this.rewardAmount,
    this.paymentStatus = 'completed',
    this.averageRating = 5.0,
    required this.images,
    DateTime? completedDate,
  }) : completedDate = completedDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'historyId': historyId,
      'originalPostId': originalPostId,
      'postId': originalPostId,
      'claimId': claimId,
      'posterId': posterId,
      'ownerId': posterId,
      'finderId': finderId,
      'ownerName': ownerName,
      'finderName': finderName,
      'ownerRating': ownerRating,
      'finderRating': finderRating,
      'ownerReview': ownerReview,
      'finderReview': finderReview,
      'status': status,
      'title': title,
      'category': category,
      'location': location,
      'rewardAmount': rewardAmount,
      'paymentStatus': paymentStatus,
      'averageRating': averageRating,
      'images': images,
      'completedDate': completedDate.toIso8601String(),
      'completedAt': completedDate.toIso8601String(),
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map, String id) {
    return HistoryModel(
      historyId: id,
      originalPostId: map['originalPostId'] ?? map['postId'] ?? '',
      claimId: map['claimId'] ?? '',
      posterId: map['posterId'] ?? map['ownerId'] ?? '',
      finderId: map['finderId'] ?? '',
      ownerName: map['ownerName'] ?? 'Item Owner',
      finderName: map['finderName'] ?? 'Finder',
      ownerRating: (map['ownerRating'] as num?)?.toDouble() ?? 5.0,
      finderRating: (map['finderRating'] as num?)?.toDouble() ?? 5.0,
      ownerReview: map['ownerReview'] ?? '',
      finderReview: map['finderReview'] ?? '',
      status: map['status'] ?? 'completed',
      title: map['title'] ?? 'Recovered Item',
      category: map['category'] ?? 'General',
      location: map['location'] ?? '',
      rewardAmount: (map['rewardAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: map['paymentStatus'] ?? 'completed',
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 5.0,
      images: List<String>.from(map['images'] ?? []),
      completedDate: _parseDateTime(map['completedDate'] ?? map['completedAt']),
    );
  }
}

class WalletModel {
  final String userId;
  final double totalEarned;
  final double todayEarned;
  final double monthlyEarned;
  final double lifetimeEarned;
  final DateTime lastUpdated;

  WalletModel({
    required this.userId,
    this.totalEarned = 0.0,
    this.todayEarned = 0.0,
    this.monthlyEarned = 0.0,
    this.lifetimeEarned = 0.0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalEarned': totalEarned,
      'todayEarned': todayEarned,
      'monthlyEarned': monthlyEarned,
      'lifetimeEarned': lifetimeEarned,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map, String id) {
    return WalletModel(
      userId: id,
      totalEarned: (map['totalEarned'] as num?)?.toDouble() ?? 0.0,
      todayEarned: (map['todayEarned'] as num?)?.toDouble() ?? 0.0,
      monthlyEarned: (map['monthlyEarned'] as num?)?.toDouble() ?? 0.0,
      lifetimeEarned: (map['lifetimeEarned'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: _parseDateTime(map['lastUpdated']),
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
