class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String postId;
  final String postTitle;
  final String postImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.postId,
    required this.postTitle,
    this.postImage = '',
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'postId': postId,
      'postTitle': postTitle,
      'postImage': postImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatRoomModel(
      id: docId,
      participants: List<String>.from(map['participants'] ?? []),
      postId: map['postId'] ?? '',
      postTitle: map['postTitle'] ?? '',
      postImage: map['postImage'] ?? '',
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null ? DateTime.parse(map['lastMessageTime']) : DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
    );
  }
}

class ChatMessageModel {
  final String id;
  final String senderId;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl = '',
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatMessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
