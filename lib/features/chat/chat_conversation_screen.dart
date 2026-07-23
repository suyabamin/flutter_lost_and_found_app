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
  ConsumerState<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends ConsumerState<ChatConversationScreen> {
  final TextEditingController _msgController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    final user = ref.read(currentUserProvider).value;
    final authUser = FirebaseAuth.instance.currentUser;
    final currentUid = user?.uid ?? authUser?.uid ?? 'guest';

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
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send message. Please check connection.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendImageAttachment() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked == null) return;

      final cloudinaryService = ref.read(cloudinaryServiceProvider);
      final imageUrl = await cloudinaryService.uploadXFile(picked);

      final user = ref.read(currentUserProvider).value;
      final authUser = FirebaseAuth.instance.currentUser;
      final currentUid = user?.uid ?? authUser?.uid ?? 'guest';

      final msg = ChatMessageModel(
        id: 'msg_img_${DateTime.now().millisecondsSinceEpoch}',
        senderId: currentUid,
        text: imageUrl,
        timestamp: DateTime.now(),
      );

      await ref.read(firestoreServiceProvider).sendMessage(widget.id, msg);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error attaching image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestoreService = ref.watch(firestoreServiceProvider);
    final user = ref.watch(currentUserProvider).value;
    final authUser = FirebaseAuth.instance.currentUser;
    final String currentUid = user?.uid ?? authUser?.uid ?? 'guest';

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
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text('Online • Private 1-to-1 Room', style: TextStyle(fontSize: 11, color: Colors.green)),
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
                    const SnackBar(content: Text('Private chat room end-to-end coordinated for lost/found item return.')),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessageModel>>(
                  stream: firestoreService.streamMessages(widget.id),
                  builder: (context, snapshot) {
                    final dbMessages = snapshot.data ?? [];

                    final List<ChatMessageModel> displayMessages = dbMessages.isEmpty
                        ? [
                            ChatMessageModel(
                              id: 'system_welcome',
                              senderId: 'system',
                              text: '🎉 Claim Approved! You can now chat in private to coordinate item handoff.',
                              timestamp: DateTime.now(),
                            )
                          ]
                        : dbMessages;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayMessages.length,
                      itemBuilder: (context, index) {
                        final msg = displayMessages[index];
                        final isMe = msg.senderId == currentUid;
                        final isImage = msg.text.startsWith('http') || msg.text.startsWith('data:image');
                        final isSystem = msg.senderId == 'system';

                        if (isSystem) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user_rounded, color: AppColors.secondary, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    msg.text,
                                    style: const TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: isImage ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : (isDark ? AppColors.darkSurface : Colors.grey.shade200),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                              ),
                            ),
                            child: isImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.network(
                                      msg.text,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(Icons.broken_image_rounded),
                                      ),
                                    ),
                                  )
                                : Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Message Input Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border(top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5))),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
                        onPressed: _sendImageAttachment,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: _isSending
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send_rounded, color: AppColors.primary),
                        onPressed: _sendMessage,
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
