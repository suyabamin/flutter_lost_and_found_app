import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/models/chat_model.dart';
import '../../core/providers/providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final authUser = FirebaseAuth.instance.currentUser;
    final firestoreService = ref.watch(firestoreServiceProvider);
    final String currentUserId = user?.uid ?? authUser?.uid ?? 'guest';

    final mockChats = [
      ChatRoomModel(
        id: 'chat_sample_1',
        participants: ['user_1', 'user_2'],
        postId: 'post_1',
        postTitle: 'Silver iPhone 14 Pro',
        postImage: 'https://picsum.photos/seed/chat1/100/100',
        lastMessage: 'Claim approved! Let us arrange item handoff.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 12)),
        unreadCount: 1,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages & Active Chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: firestoreService.streamChatRooms(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final dbChats = snapshot.data ?? [];
          final allChats = [...dbChats, ...mockChats];

          if (allChats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.outline),
                  SizedBox(height: 12),
                  Text('No active conversations yet.', style: TextStyle(fontSize: 16, color: AppColors.outline)),
                  SizedBox(height: 4),
                  Text('Approved claims will open private 1-to-1 chat rooms here.', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: allChats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chat = allChats[index];
              final String timeStr = '${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}';

              return GlassContainer(
                onTap: () => context.push('/chat/${chat.id}'),
                borderRadius: 18,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(
                        chat.postImage.isNotEmpty ? chat.postImage : 'https://picsum.photos/seed/${chat.id}/100/100',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(chat.postTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: chat.unreadCount > 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                              fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.outline)),
                        const SizedBox(height: 6),
                        if (chat.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${chat.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
