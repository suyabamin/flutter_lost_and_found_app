import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/chat_model.dart';
import '../models/claim_model.dart';
import '../models/recovery_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _usersRef => _db.collection('users');
  CollectionReference get _postsRef => _db.collection('posts');
  CollectionReference get _chatRoomsRef => _db.collection('chat_rooms');
  CollectionReference get _notificationsRef => _db.collection('notifications');
  CollectionReference get _claimsRef => _db.collection('claims');
  CollectionReference get _ratingsRef => _db.collection('ratings');
  CollectionReference get _paymentsRef => _db.collection('payments');
  CollectionReference get _historyRef => _db.collection('history');
  CollectionReference get _walletRef => _db.collection('wallet');

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

  // In-memory local posts cache to ensure newly posted items are immediately available
  static final List<PostModel> _localPosts = [];

  // Maps post ID → raw image bytes for immediate local display.
  // This ensures the user's actual picked photo is always shown on this device
  // regardless of whether Cloudinary is configured or images exceeded the Base64 size limit.
  static final Map<String, List<Uint8List>> _localImageBytes = {};

  // Maps claim ID → raw claim proof image bytes for immediate local display.
  static final Map<String, List<Uint8List>> _localClaimImageBytes = {};

  /// Store raw image bytes for a post so they can be displayed immediately.
  static void storeLocalImageBytes(String postId, List<Uint8List> imageBytes) {
    if (imageBytes.isNotEmpty) {
      _localImageBytes[postId] = imageBytes;
    }
  }

  /// Get locally stored image bytes for a post (returns null if not on this device/session).
  static List<Uint8List>? getLocalImageBytes(String postId) {
    return _localImageBytes[postId];
  }

  /// Store raw claim proof image bytes for immediate local display.
  static void storeLocalClaimImageBytes(String claimId, List<Uint8List> imageBytes) {
    if (imageBytes.isNotEmpty) {
      _localClaimImageBytes[claimId] = imageBytes;
    }
  }

  /// Get locally stored claim image bytes (returns null if not on this device/session).
  static List<Uint8List>? getLocalClaimImageBytes(String claimId) {
    return _localClaimImageBytes[claimId];
  }


  // POSTS CRUD
  Future<void> createPost(PostModel post) async {
    // 1. Instantly save to local memory store
    _localPosts.removeWhere((p) => p.id == post.id);
    _localPosts.insert(0, post);

    // 2. Persist to Cloud Firestore (uses Base64/URL version, safe for cross-device access)
    try {
      await _postsRef.doc(post.id).set(post.toMap());
    } catch (e) {
      print('Firestore createPost notice: $e');
    }
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
      final firestorePosts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((p) => p.status == 'active' || (p.status != 'completed' && p.status != 'resolved' && p.status != 'archived' && p.status != 'closed'))
          .where((p) => p.status != 'completed' && p.status != 'resolved' && p.status != 'archived' && p.status != 'closed')
          .toList();

      final firestoreIds = firestorePosts.map((p) => p.id).toSet();
      final localFiltered = _localPosts.where((lp) {
        if (lp.status == 'completed' || lp.status == 'resolved' || lp.status == 'archived' || lp.status == 'closed') return false;
        if (firestoreIds.contains(lp.id)) return false;
        if (category != null && category != 'All' && lp.category != category) return false;
        if (type != null && lp.type != type) return false;
        return true;
      });

      final combined = [...localFiltered, ...firestorePosts];
      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return combined;
    }).handleError((_) {
      final localFiltered = _localPosts.where((lp) {
        if (lp.status == 'completed' || lp.status == 'resolved' || lp.status == 'archived' || lp.status == 'closed') return false;
        if (category != null && category != 'All' && lp.category != category) return false;
        if (type != null && lp.type != type) return false;
        return true;
      }).toList();
      localFiltered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return localFiltered;
    });
  }

  Stream<List<PostModel>> streamUserPosts(String userId) {
    return _postsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final firestorePosts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      final firestoreIds = firestorePosts.map((p) => p.id).toSet();
      final localFiltered = _localPosts.where((lp) => (lp.userId == userId || userId.startsWith('guest')) && !firestoreIds.contains(lp.id));

      final combined = [...localFiltered, ...firestorePosts];
      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return combined;
    }).handleError((_) {
      final localFiltered = _localPosts.where((lp) => lp.userId == userId || userId.startsWith('guest')).toList();
      localFiltered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return localFiltered;
    });
  }

  Future<PostModel?> getPost(String id) async {
    // Check local store first for instant access
    for (final p in _localPosts) {
      if (p.id == id) return p;
    }

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

  // ─────────────────────────────────────────────────────────────
  // RECOVERY & DUAL CONFIRMATION
  // ─────────────────────────────────────────────────────────────
  Future<void> confirmRecovery({required String claimId, required bool isOwner}) async {
    try {
      final nowStr = DateTime.now().toIso8601String();
      final claimDoc = await _claimsRef.doc(claimId).get();
      if (!claimDoc.exists) return;

      final data = claimDoc.data() as Map<String, dynamic>;
      final claim = ClaimModel.fromMap(data, claimDoc.id);
      final updates = <String, dynamic>{};

      if (isOwner) {
        updates['ownerConfirmedAt'] = nowStr;
      } else {
        updates['finderConfirmedAt'] = nowStr;
      }

      final hasOwnerConfirmed = isOwner || (data['ownerConfirmedAt'] != null);
      final hasFinderConfirmed = !isOwner || (data['finderConfirmedAt'] != null);

      if (hasOwnerConfirmed && hasFinderConfirmed) {
        updates['recoveryStatus'] = 'both_confirmed';
      }

      await _claimsRef.doc(claimId).update(updates);

      // Send Notifications
      if (isOwner) {
        await createNotification({
          'id': 'notif_rate_finder_${claimId}_${DateTime.now().millisecondsSinceEpoch}',
          'userId': claim.postOwnerId,
          'title': 'Rate Finder 🌟',
          'body': 'Please rate the Finder for returning your item.',
          'claimId': claimId,
          'postId': claim.postId,
          'type': 'rating_request',
          'isRead': false,
          'timestamp': nowStr,
        });

        await createNotification({
          'id': 'notif_owner_confirmed_${claimId}_${DateTime.now().millisecondsSinceEpoch}',
          'userId': claim.claimerId,
          'title': 'Owner Confirmed Recovery ✅',
          'body': 'Owner confirmed receipt of item. Please rate the Owner.',
          'claimId': claimId,
          'postId': claim.postId,
          'type': 'rating_request',
          'isRead': false,
          'timestamp': nowStr,
        });
      } else {
        await createNotification({
          'id': 'notif_rate_owner_${claimId}_${DateTime.now().millisecondsSinceEpoch}',
          'userId': claim.claimerId,
          'title': 'Rate Owner 🌟',
          'body': 'Please rate the Owner after returning their item.',
          'claimId': claimId,
          'postId': claim.postId,
          'type': 'rating_request',
          'isRead': false,
          'timestamp': nowStr,
        });

        await createNotification({
          'id': 'notif_finder_confirmed_${claimId}_${DateTime.now().millisecondsSinceEpoch}',
          'userId': claim.postOwnerId,
          'title': 'Finder Confirmed Return ✅',
          'body': 'Finder confirmed item return. Please rate the Finder.',
          'claimId': claimId,
          'postId': claim.postId,
          'type': 'rating_request',
          'isRead': false,
          'timestamp': nowStr,
        });
      }

      // Check if all 4 conditions are satisfied
      await checkAndArchivePost(claimId);
    } catch (e) {
      print('confirmRecovery notice: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // PAYMENT CRUD & CONFIRMATION
  // ─────────────────────────────────────────────────────────────
  Future<void> createPayment(PaymentModel payment) async {
    try {
      await _paymentsRef.doc(payment.paymentId).set(payment.toMap());

      // Update Finder's Wallet immediately upon reward payment creation
      await updateWallet(userId: payment.finderId, addAmount: payment.amount);

      // Send notification to finder
      await createNotification({
        'id': 'notif_payment_${payment.paymentId}',
        'userId': payment.finderId,
        'title': 'Reward Sent 💰',
        'body': 'Post owner sent ৳ ${payment.amount.toInt()} reward via ${payment.method}. Transaction ID: ${payment.transactionId}',
        'claimId': payment.claimId,
        'postId': payment.postId,
        'type': 'reward_payment',
        'isRead': false,
      });
    } catch (_) {}
  }

  Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final doc = await _paymentsRef.doc(paymentId).get();
      if (doc.exists && doc.data() != null) {
        return PaymentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (_) {}
    return null;
  }

  Stream<PaymentModel?> streamPayment(String paymentId) {
    return _paymentsRef.doc(paymentId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return PaymentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    }).handleError((_) => null);
  }

  Stream<PaymentModel?> streamPaymentForClaim(String claimId) {
    return _paymentsRef.where('claimId', isEqualTo: claimId).snapshots().map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return PaymentModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
      }
      return null;
    }).handleError((_) => null);
  }

  Future<void> confirmPaymentReceived(String paymentId) async {
    try {
      final nowStr = DateTime.now().toIso8601String();
      final doc = await _paymentsRef.doc(paymentId).get();
      if (!doc.exists) return;

      final payment = PaymentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

      // Update payment status to completed
      await _paymentsRef.doc(paymentId).update({
        'status': 'completed',
        'confirmedAt': nowStr,
      });

      // Update Finder's Wallet
      await updateWallet(userId: payment.finderId, addAmount: payment.amount);

      // Update claim status to completed
      await _claimsRef.doc(payment.claimId).update({
        'status': 'completed',
      });

      // Archive post into history
      await archiveToHistory(
        claimId: payment.claimId,
        postId: payment.postId,
        paymentStatus: 'paid',
        paidAmount: payment.amount,
      );

      // Notify poster
      await createNotification({
        'id': 'notif_payment_confirmed_$paymentId',
        'userId': payment.posterId,
        'title': 'Recovery Completed 🎉',
        'body': 'Finder confirmed reward receipt of ৳ ${payment.amount.toInt()}. Item recovery is complete!',
        'claimId': payment.claimId,
        'postId': payment.postId,
        'type': 'recovery_completed',
        'isRead': false,
        'timestamp': nowStr,
      });
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  // AUTO ARCHIVE & ALL 4 CONDITIONS CHECK
  // ─────────────────────────────────────────────────────────────
  Future<bool> checkAndArchivePost(String claimId) async {
    try {
      final claimDoc = await _claimsRef.doc(claimId).get();
      if (!claimDoc.exists || claimDoc.data() == null) return false;

      final claimData = claimDoc.data() as Map<String, dynamic>;
      final claim = ClaimModel.fromMap(claimData, claimDoc.id);

      final hasOwnerConfirmed = claim.ownerConfirmedAt != null;
      final hasFinderConfirmed = claim.finderConfirmedAt != null;

      if (!hasOwnerConfirmed || !hasFinderConfirmed) {
        return false;
      }

      final ratingsSnap = await _ratingsRef.where('claimId', isEqualTo: claimId).get();
      final ratingDocs = ratingsSnap.docs;

      bool hasOwnerRated = false;
      bool hasFinderRated = false;
      double ownerRatingVal = 5.0;
      double finderRatingVal = 5.0;
      String ownerRev = '';
      String finderRev = '';

      for (final doc in ratingDocs) {
        final rData = doc.data() as Map<String, dynamic>;
        final from = rData['fromUserId'] ?? rData['fromUser'] ?? '';
        final rVal = (rData['rating'] as num?)?.toDouble() ?? 5.0;
        final rev = rData['review']?.toString() ?? '';

        if (from == claim.postOwnerId) {
          hasOwnerRated = true;
          ownerRatingVal = rVal;
          ownerRev = rev;
        }
        if (from == claim.claimerId) {
          hasFinderRated = true;
          finderRatingVal = rVal;
          finderRev = rev;
        }
      }

      // Verify ALL 4 CONDITIONS
      if (hasOwnerConfirmed && hasFinderConfirmed && hasOwnerRated && hasFinderRated) {
        final post = await getPost(claim.postId);
        final historyId = 'hist_${claimId}';
        final historyDoc = await _historyRef.doc(historyId).get();

        if (!historyDoc.exists) {
          final ownerUser = await getUser(claim.postOwnerId);
          final finderUser = await getUser(claim.claimerId);

          final avgRating = double.parse(((ownerRatingVal + finderRatingVal) / 2.0).toStringAsFixed(1));

          final history = HistoryModel(
            historyId: historyId,
            originalPostId: claim.postId,
            claimId: claimId,
            posterId: claim.postOwnerId,
            finderId: claim.claimerId,
            ownerName: ownerUser?.displayName ?? 'Item Owner',
            finderName: finderUser?.displayName ?? 'Finder',
            ownerRating: ownerRatingVal,
            finderRating: finderRatingVal,
            ownerReview: ownerRev,
            finderReview: finderRev,
            status: 'completed',
            title: post?.title ?? 'Recovered Item',
            category: post?.category ?? 'General',
            location: post?.location ?? '',
            rewardAmount: post?.rewardAmount ?? claim.rewardRequested,
            paymentStatus: 'completed',
            averageRating: avgRating,
            images: post?.images ?? [],
            completedDate: DateTime.now(),
          );

          await _historyRef.doc(historyId).set(history.toMap());
          await _postsRef.doc(claim.postId).update({'status': 'completed', 'completedClaimId': claimId});

          // Remove completed post from local memory feed store immediately
          _localPosts.removeWhere((p) => p.id == claim.postId);

          await _claimsRef.doc(claimId).update({
            'status': 'completed',
            'recoveryStatus': 'completed',
          });

          await _incrementUserRecoveryStatsFull(claim.postOwnerId, isOwner: true, viaClaimId: claimId);
          await _incrementUserRecoveryStatsFull(claim.claimerId, isOwner: false, viaClaimId: claimId);

          final nowStr = DateTime.now().toIso8601String();
          await createNotification({
            'id': 'notif_rec_complete_owner_${claimId}',
            'userId': claim.postOwnerId,
            'title': 'Recovery Completed Successfully 🎉',
            'body': 'Recovery completed successfully. Your post has been archived to History.',
            'claimId': claimId,
            'postId': claim.postId,
            'type': 'recovery_completed',
            'isRead': false,
            'timestamp': nowStr,
          });

          await createNotification({
            'id': 'notif_rec_complete_finder_${claimId}',
            'userId': claim.claimerId,
            'title': 'Recovery Completed Successfully 🎉',
            'body': 'Recovery completed successfully. Your return record has been saved to History.',
            'claimId': claimId,
            'postId': claim.postId,
            'type': 'recovery_completed',
            'isRead': false,
            'timestamp': nowStr,
          });

          return true;
        }
      }
    } catch (e) {
      print('checkAndArchivePost notice: $e');
    }
    return false;
  }

  Future<void> _incrementUserRecoveryStatsFull(String userId,
      {required bool isOwner, String? viaClaimId}) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final recoveries = (data['completedRecoveries'] as num?)?.toInt() ?? 0;
        final returns = (data['completedReturns'] as num?)?.toInt() ?? 0;
        final successful = (data['successfulRecoveryCount'] as num?)?.toInt() ?? 0;
        final pts = (data['rewardPoints'] as num?)?.toInt() ?? 0;

        final updates = <String, dynamic>{
          'successfulRecoveryCount': successful + 1,
          'rewardPoints': pts + 50,
        };

        if (isOwner) {
          updates['completedRecoveries'] = recoveries + 1;
        } else {
          updates['completedReturns'] = returns + 1;
        }

        // Claim-ভেরিফিকেশন মার্কার: Firestore rules-কে জানায় কোন recovery claim থেকে
        // এই stats আপডেট এসেছে, যাতে এই claim-এর অন্য পক্ষের doc-ও আপডেট করা যায়।
        if (viaClaimId != null && viaClaimId.isNotEmpty) {
          updates['updatedViaClaimId'] = viaClaimId;
        }

        await _usersRef.doc(userId).update(updates);
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  // ARCHIVE TO HISTORY
  // ─────────────────────────────────────────────────────────────
  Future<void> archiveToHistory({
    required String claimId,
    required String postId,
    required String paymentStatus,
    double paidAmount = 0.0,
  }) async {
    try {
      final post = await getPost(postId);
      final claim = await getClaim(claimId);
      if (post == null || claim == null) return;

      final historyId = 'hist_${claimId}';
      final historyDoc = await _historyRef.doc(historyId).get();

      if (!historyDoc.exists) {
        final history = HistoryModel(
          historyId: historyId,
          originalPostId: postId,
          claimId: claimId,
          posterId: claim.postOwnerId,
          finderId: claim.claimerId,
          title: post.title,
          category: post.category,
          location: post.location,
          rewardAmount: paidAmount > 0 ? paidAmount : post.rewardAmount,
          paymentStatus: paymentStatus,
          averageRating: 5.0,
          images: post.images,
          completedDate: DateTime.now(),
        );

        await _historyRef.doc(historyId).set(history.toMap());

        // Update post status to resolved and remove from local active feed
        await _postsRef.doc(postId).update({'status': 'resolved'});
        _localPosts.removeWhere((p) => p.id == postId);

        // Increment completed recoveries count on both users
        await _incrementUserRecoveryStats(claim.postOwnerId);
        await _incrementUserRecoveryStats(claim.claimerId);
      }
    } catch (_) {}
  }

  Future<void> _incrementUserRecoveryStats(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final count = (data['completedRecoveries'] as num?)?.toInt() ?? 0;
        final pts = (data['rewardPoints'] as num?)?.toInt() ?? 0;
        await _usersRef.doc(userId).update({
          'completedRecoveries': count + 1,
          'rewardPoints': pts + 50,
        });
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  // RATINGS & REVIEWS
  // ─────────────────────────────────────────────────────────────
  Future<void> createRating(RatingModel rating) async {
    // 1. Persist the rating (and its review duplicate) to Firestore.
    try {
      await _ratingsRef.doc(rating.ratingId).set(rating.toMap());
      await _db.collection('reviews').doc(rating.ratingId).set(rating.toMap());
    } catch (e) {
      print('createRating save notice: $e');
    }

    // 2. Recalculate average rating & total reviews for target user.
    //    Best-effort: a failure here must NOT block the archive check below,
    //    otherwise the post would never be removed from the active feed
    //    even after both participants have rated.
    try {
      final targetUid = rating.toUserId.isNotEmpty ? rating.toUserId : rating.toUser;
      final snapshot = await _ratingsRef.where('toUserId', isEqualTo: targetUid).get();
      final docs = snapshot.docs.isNotEmpty ? snapshot.docs : (await _ratingsRef.where('toUser', isEqualTo: targetUid).get()).docs;

      if (docs.isNotEmpty) {
        double total = 0.0;
        for (final d in docs) {
          total += (d.data() as Map<String, dynamic>)['rating'] as num? ?? 5.0;
        }
        final avg = double.parse((total / docs.length).toStringAsFixed(1));
        await _usersRef.doc(targetUid).update({
          'averageRating': avg,
          'totalReviews': docs.length,
          'totalRatings': docs.length,
          'trustScore': ((avg / 5.0) * 100).round(),
          // Claim-ভেরিফিকেশন মার্কার: রেটার এই claim-এর অন্য পক্ষ বলে প্রমাণ করা হয়
          'updatedViaClaimId': rating.claimId,
        });
      }
    } catch (e) {
      print('createRating stats notice: $e');
    }

    // 3. Check if ALL 4 conditions are met and auto-archive the post.
    //    Runs even if step 2 failed, so a completed post is always removed
    //    from the active feed once both participants have rated.
    await checkAndArchivePost(rating.claimId);
  }

  Stream<List<RatingModel>> streamRatingsForUser(String userId) {
    return _ratingsRef.where('toUser', isEqualTo: userId).snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => RatingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }).handleError((_) => <RatingModel>[]);
  }

  Stream<RatingModel?> streamUserRatingForClaim(String claimId, String fromUserId) {
    return _ratingsRef
        .where('claimId', isEqualTo: claimId)
        .where('fromUser', isEqualTo: fromUserId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return RatingModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>, snapshot.docs.first.id);
      }
      return null;
    }).handleError((_) => null);
  }

  // ─────────────────────────────────────────────────────────────
  // WALLET & EARNINGS
  // ─────────────────────────────────────────────────────────────
  Future<void> updateWallet({required String userId, required double addAmount}) async {
    try {
      final doc = await _walletRef.doc(userId).get();
      double total = 0.0;
      double today = 0.0;
      double monthly = 0.0;
      double lifetime = 0.0;

      if (doc.exists && doc.data() != null) {
        final w = WalletModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        total = w.totalEarned + addAmount;
        today = w.todayEarned + addAmount;
        monthly = w.monthlyEarned + addAmount;
        lifetime = w.lifetimeEarned + addAmount;
      } else {
        total = addAmount;
        today = addAmount;
        monthly = addAmount;
        lifetime = addAmount;
      }

      final wallet = WalletModel(
        userId: userId,
        totalEarned: total,
        todayEarned: today,
        monthlyEarned: monthly,
        lifetimeEarned: lifetime,
        lastUpdated: DateTime.now(),
      );

      await _walletRef.doc(userId).set(wallet.toMap());
    } catch (_) {}
  }

  Stream<WalletModel?> streamWallet(String userId) {
    return _walletRef.doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return WalletModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return WalletModel(userId: userId);
    }).handleError((_) => WalletModel(userId: userId));
  }

  Stream<List<PaymentModel>> streamUserPayments(String userId) {
    return _paymentsRef.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => PaymentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((p) => p.posterId == userId || p.finderId == userId)
          .toList();
      list.sort((a, b) => b.paidAt.compareTo(a.paidAt));
      return list;
    }).handleError((_) => <PaymentModel>[]);
  }

  // ─────────────────────────────────────────────────────────────
  // HISTORY FEED STREAM
  // ─────────────────────────────────────────────────────────────
  Stream<List<HistoryModel>> streamUserHistory(String userId) {
    return _historyRef.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => HistoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((h) => h.posterId == userId || h.finderId == userId)
          .toList();
      list.sort((a, b) => b.completedDate.compareTo(a.completedDate));
      return list;
    }).handleError((_) => <HistoryModel>[]);
  }

  // ─────────────────────────────────────────────────────────────
  // LEADERBOARD STREAM
  // ─────────────────────────────────────────────────────────────
  Stream<List<UserModel>> streamLeaderboard() {
    return _usersRef.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      list.sort((a, b) => (b.rewardPoints).compareTo(a.rewardPoints));
      return list;
    }).handleError((_) => <UserModel>[]);
  }
}

