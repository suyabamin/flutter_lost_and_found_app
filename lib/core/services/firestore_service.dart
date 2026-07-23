import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/chat_model.dart';
import '../models/claim_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _usersRef => _db.collection('users');
  CollectionReference get _postsRef => _db.collection('posts');
  CollectionReference get _chatRoomsRef => _db.collection('chat_rooms');
  CollectionReference get _notificationsRef => _db.collection('notifications');
  CollectionReference get _claimsRef => _db.collection('claims');

  // USER CRUD
  Future<void> saveUser(UserModel user) async {
    try {
      await _usersRef.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (_) {}
    return null;
  }

  Stream<UserModel?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    }).handleError((_) => null);
  }

  // POSTS CRUD
  Future<void> createPost(PostModel post) async {
    try {
      await _postsRef.doc(post.id).set(post.toMap());
    } catch (_) {}
  }

  Stream<List<PostModel>> streamPosts({String? category, String? type}) {
    Query query = _postsRef;
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    return query.snapshots().map((snapshot) {
      final posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    }).handleError((_) => <PostModel>[]);
  }

  Stream<List<PostModel>> streamUserPosts(String userId) {
    return _postsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    }).handleError((_) => <PostModel>[]);
  }

  Future<PostModel?> getPost(String id) async {
    try {
      final doc = await _postsRef.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (_) {}
    return null;
  }

  // CLAIMS CRUD & WORKFLOW
  Future<void> createClaim(ClaimModel claim) async {
    try {
      await _claimsRef.doc(claim.claimId).set(claim.toMap());

      final now = DateTime.now().toIso8601String();

      // 1. Send notification to post owner
      await createNotification({
        'id': 'notif_${claim.claimId}_owner',
        'userId': claim.postOwnerId,
        'title': 'New Claim Received 📩',
        'body': '${claim.claimerName} submitted a claim for your item.',
        'claimId': claim.claimId,
        'postId': claim.postId,
        'type': 'claim',
        'isRead': false,
        'timestamp': now,
      });

      // 2. Send notification to claimer
      await createNotification({
        'id': 'notif_${claim.claimId}_claimer',
        'userId': claim.claimerId,
        'title': 'Claim Submitted Successfully 🎉',
        'body': 'Your claim has been submitted to the item poster for review.',
        'claimId': claim.claimId,
        'postId': claim.postId,
        'type': 'claim',
        'isRead': false,
        'timestamp': now,
      });
    } catch (e) {
      print('Claim save notice: $e');
      rethrow;
    }
  }

  Future<ClaimModel?> getClaim(String claimId) async {
    try {
      final doc = await _claimsRef.doc(claimId).get();
      if (doc.exists && doc.data() != null) {
        return ClaimModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (_) {}
    return null;
  }

  Stream<ClaimModel?> streamClaim(String claimId) {
    return _claimsRef.doc(claimId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return ClaimModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    }).handleError((_) => null);
  }

  Stream<List<ClaimModel>> streamClaimsForPost(String postId) {
    return _claimsRef.where('postId', isEqualTo: postId).snapshots().map((snapshot) {
      final claims = snapshot.docs
          .map((doc) => ClaimModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      claims.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return claims;
    }).handleError((_) => <ClaimModel>[]);
  }

  Future<void> updateClaimStatus(String claimId, String status) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };
      if (status == 'approved') {
        updates['approvedAt'] = DateTime.now().toIso8601String();
      } else if (status == 'rejected') {
        updates['rejectedAt'] = DateTime.now().toIso8601String();
      }

      await _claimsRef.doc(claimId).update(updates);

      // Notify claimer
      final claim = await getClaim(claimId);
      if (claim != null) {
        await createNotification({
          'id': 'notif_${claimId}_status_${DateTime.now().millisecondsSinceEpoch}',
          'userId': claim.claimerId,
          'title': status == 'approved' ? 'Claim Approved! ✅' : 'Claim Status Updated ❌',
          'body': status == 'approved'
              ? 'Your claim was approved! Private chat room opened.'
              : 'Your claim for this item was rejected by owner.',
          'claimId': claimId,
          'postId': claim.postId,
          'type': 'claim_status',
          'isRead': false,
          'timestamp': DateTime.now().toIso8601String(),
        });

        // If approved, automatically create private 1-to-1 chat room
        if (status == 'approved') {
          await createOrGetChatRoom(
            posterId: claim.postOwnerId,
            claimerId: claim.claimerId,
            postId: claim.postId,
            postTitle: 'Claim Approved: ${claim.description.length > 20 ? claim.description.substring(0, 20) : claim.description}',
            postImage: claim.claimImages.isNotEmpty ? claim.claimImages.first : '',
          );
        }
      }
    } catch (_) {}
  }

  Future<void> updateLiveLocation({
    required String claimId,
    required bool isOwner,
    required bool isSharing,
    required double lat,
    required double lng,
  }) async {
    try {
      if (isOwner) {
        await _claimsRef.doc(claimId).update({
          'isOwnerSharingLocation': isSharing,
          'ownerLat': lat,
          'ownerLng': lng,
        });
      } else {
        await _claimsRef.doc(claimId).update({
          'isClaimerSharingLocation': isSharing,
          'claimerLat': lat,
          'claimerLng': lng,
        });
      }
    } catch (_) {}
  }

  // NOTIFICATIONS CRUD
  Future<void> createNotification(Map<String, dynamic> notifData) async {
    try {
      final id = notifData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      await _notificationsRef.doc(id).set(notifData);
    } catch (_) {}
  }

  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _notificationsRef
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      
      // Sort notifications by timestamp descending (newest first)
      list.sort((a, b) {
        final aTime = a['timestamp']?.toString() ?? '';
        final bTime = b['timestamp']?.toString() ?? '';
        return bTime.compareTo(aTime);
      });

      if (userId.isNotEmpty && userId != 'guest') {
        return list.where((data) {
          final targetId = data['userId']?.toString() ?? '';
          return targetId == userId || targetId.isEmpty || targetId == 'guest' || targetId.startsWith('guest_') || targetId.startsWith('claimer_');
        }).toList();
      }
      return list;
    }).handleError((_) => <Map<String, dynamic>>[]);
  }

  // CHAT CRUD & AUTO CHAT CREATION
  Future<String> createOrGetChatRoom({
    required String posterId,
    required String claimerId,
    required String postId,
    required String postTitle,
    required String postImage,
  }) async {
    final roomId = 'chat_${postId}_${posterId}_$claimerId';
    try {
      final doc = await _chatRoomsRef.doc(roomId).get();

      if (!doc.exists) {
        final room = ChatRoomModel(
          id: roomId,
          participants: [posterId, claimerId],
          postId: postId,
          postTitle: postTitle,
          postImage: postImage.isNotEmpty ? postImage : 'https://picsum.photos/seed/$postId/100/100',
          lastMessage: 'Claim approved. You can now chat and coordinate return.',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
        );
        await _chatRoomsRef.doc(roomId).set(room.toMap());
      }
    } catch (_) {}

    return roomId;
  }

  Future<ChatRoomModel?> getChatRoom(String roomId) async {
    try {
      final doc = await _chatRoomsRef.doc(roomId).get();
      if (doc.exists && doc.data() != null) {
        return ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (_) {}
    return null;
  }

  Stream<List<ChatRoomModel>> streamChatRooms(String userId) {
    return _chatRoomsRef
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs
          .map((doc) => ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((room) => userId.isEmpty || room.participants.contains(userId) || userId.startsWith('guest_') || userId.startsWith('claimer_'))
          .toList();
      rooms.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return rooms;
    }).handleError((_) => <ChatRoomModel>[]);
  }

  Stream<List<ChatMessageModel>> streamMessages(String chatRoomId) {
    return _chatRoomsRef
        .doc(chatRoomId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      final msgs = snapshot.docs
          .map((doc) => ChatMessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return msgs;
    }).handleError((_) => <ChatMessageModel>[]);
  }

  Future<void> sendMessage(String chatRoomId, ChatMessageModel msg) async {
    try {
      await _chatRoomsRef.doc(chatRoomId).collection('messages').doc(msg.id).set(msg.toMap());
      await _chatRoomsRef.doc(chatRoomId).update({
        'lastMessage': msg.text.isNotEmpty ? msg.text : '📷 Image',
        'lastMessageTime': msg.timestamp.toIso8601String(),
      });
    } catch (_) {}
  }
}
