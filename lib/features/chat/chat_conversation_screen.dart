import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/chat_model.dart';
import '../../core/providers/providers.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final String id;

  const ChatConversationScreen({super.key, required this.id});

  @override
  ConsumerState<ChatConversationScreen> createState() =>
      _ChatConversationScreenState();
}

class _ChatConversationScreenState
    extends ConsumerState<ChatConversationScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    _msgController.clear();
    setState(() => _isSending = true);

    try {
      final msg = ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: currentUid,
        text: text,
        timestamp: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).sendMessage(widget.id, msg);
      _scrollToBottom();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not send message. Please check connection.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendImageAttachment() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 50,
      );
      if (picked == null) return;

      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      final imageUrl = await cloudinaryService.uploadXFile(picked);

      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

      final msg = ChatMessageModel(
        id: 'msg_img_${DateTime.now().millisecondsSinceEpoch}',
        senderId: currentUid,
        text: imageUrl,
        timestamp: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).sendMessage(widget.id, msg);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error attaching image: $e')));
      }
    }
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestoreService = ref.watch(firestoreServiceProvider);

    // Use FirebaseAuth directly (synchronous) — avoids async StreamProvider null bug
    // where isMe is always false and all messages appear on the same side.
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    return FutureBuilder<ChatRoomModel?>(
      future: firestoreService.getChatRoom(widget.id),
      builder: (context, chatRoomSnapshot) {
        final chatRoom = chatRoomSnapshot.data;
        final String roomTitle = chatRoom?.postTitle.isNotEmpty == true
            ? chatRoom!.postTitle
            : 'Private 1-to-1 Handoff Chat';
        final String roomImage = chatRoom?.postImage.isNotEmpty == true
            ? chatRoom!.postImage
            : 'https://i.pravatar.cc/100?img=12';

        // Find the other participant's ID
        String otherUid = '';
        if (chatRoom != null) {
          for (final p in chatRoom.participants) {
            if (p != currentUid) {
              otherUid = p;
              break;
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(roomImage),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roomTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Online • Private 1-to-1 Room',
                        style: TextStyle(fontSize: 11, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Private chat room end-to-end coordinated for lost/found item return.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Message List
              Expanded(
                child: StreamBuilder<List<ChatMessageModel>>(
                  stream: firestoreService.streamMessages(widget.id),
                  builder: (context, snapshot) {
                    final dbMessages = snapshot.data ?? [];

                    final List<ChatMessageModel> displayMessages =
                        dbMessages.isEmpty
                        ? [
                            ChatMessageModel(
                              id: 'system_welcome',
                              senderId: 'system',
                              text:
                                  '?? Claim Approved! You can now chat in private to coordinate item handoff.',
                              timestamp: DateTime.now(),
                            ),
                          ]
                        : dbMessages;

                    if (dbMessages.isNotEmpty) _scrollToBottom();

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      itemCount: displayMessages.length,
                      itemBuilder: (context, index) {
                        final msg = displayMessages[index];
                        // KEY FIX: compare senderId stored in Firestore with current user's uid
                        final bool isMe = msg.senderId == currentUid;
                        final bool isSystem = msg.senderId == 'system';
                        final bool isImage =
                            msg.text.startsWith('http') ||
                            msg.text.startsWith('data:image');

                        // System announcement bubble (centered)
                        if (isSystem) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_user_rounded,
                                  color: AppColors.secondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    msg.text,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Messenger-style bubble:
                        // MY message  ? RIGHT side, blue bubble, flat bottom-right corner
                        // OTHER person ? LEFT side, grey bubble + avatar, flat bottom-left corner
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Avatar shown only for the other person's messages (on the left)
                              if (!isMe) ...[
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.18),
                                  child: Text(
                                    otherUid.isNotEmpty
                                        ? otherUid[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],

                              // Bubble + timestamp
                              Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                          0.68,
                                    ),
                                    padding: isImage
                                        ? const EdgeInsets.all(3)
                                        : const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                    decoration: BoxDecoration(
                                      // MY messages: blue (primary color)
                                      // OTHER's messages: grey
                                      color: isMe
                                          ? AppColors.primary
                                          : (isDark
                                                ? const Color(0xFF2C2C2E)
                                                : Colors.grey.shade200),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        topRight: const Radius.circular(18),
                                        // Messenger tail: bottom corner nearest the edge is flat/small
                                        bottomLeft: isMe
                                            ? const Radius.circular(18)
                                            : const Radius.circular(4),
                                        bottomRight: isMe
                                            ? const Radius.circular(4)
                                            : const Radius.circular(18),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: isImage
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                            child: Image.network(
                                              msg.text,
                                              fit: BoxFit.cover,
                                              width:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.60,
                                              errorBuilder: (_, __, ___) =>
                                                  const Padding(
                                                    padding: EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .broken_image_rounded,
                                                    ),
                                                  ),
                                            ),
                                          )
                                        : Text(
                                            msg.text,
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : (isDark
                                                        ? Colors.white
                                                        : Colors.black87),
                                              fontSize: 14.5,
                                            ),
                                          ),
                                  ),

                                  // Timestamp under each bubble
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 3,
                                      left: 4,
                                      right: 4,
                                    ),
                                    child: Text(
                                      _formatTime(msg.timestamp),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Spacer on right side for other person's messages
                              if (!isMe) const SizedBox(width: 30),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Message Input Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: _sendImageAttachment,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2C2C2E)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _msgController,
                            textInputAction: TextInputAction.send,
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: _isSending
                              ? const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
