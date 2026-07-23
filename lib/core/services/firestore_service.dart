import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/chat_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _usersRef => _db.collection('users');
  CollectionReference get _postsRef => _db.collection('posts');
  CollectionReference get _chatRoomsRef => _db.collection('chat_rooms');
  CollectionReference get _notificationsRef => _db.collection('notifications');

  // USER CRUD
  Future<void> saveUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Stream<UserModel?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }

  // POSTS CRUD
  Future<void> createPost(PostModel post) async {
    await _postsRef.doc(post.id).set(post.toMap());
  }

  Stream<List<PostModel>> streamPosts({String? category, String? type}) {
    Query query = _postsRef.orderBy('createdAt', descending: true);
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Stream<List<PostModel>> streamUserPosts(String userId) {
    return _postsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<PostModel?> getPost(String id) async {
    final doc = await _postsRef.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // NOTIFICATIONS STREAM
  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _notificationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  // CHAT CRUD
  Stream<List<ChatRoomModel>> streamChatRooms(String userId) {
    return _chatRoomsRef
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<ChatMessageModel>> streamMessages(String chatRoomId) {
    return _chatRoomsRef
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> sendMessage(String chatRoomId, ChatMessageModel msg) async {
    await _chatRoomsRef.doc(chatRoomId).collection('messages').doc(msg.id).set(msg.toMap());
    await _chatRoomsRef.doc(chatRoomId).update({
      'lastMessage': msg.text.isNotEmpty ? msg.text : '📷 Image',
      'lastMessageTime': msg.timestamp.toIso8601String(),
    });
  }
}
