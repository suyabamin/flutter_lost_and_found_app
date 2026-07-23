import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/models/chat_model.dart';
import '../../core/providers/providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final firestoreService = ref.watch(firestoreServiceProvider);

    final mockChats = [
      ChatRoomModel(
        id: 'chat_1',
        participants: ['user_1', 'user_2'],
        postId: 'post_1',
        postTitle: 'Silver iPhone 14 Pro',
        postImage: 'https://picsum.photos/seed/chat1/100/100',
        lastMessage: 'Is this item still available? I think it belongs to my brother.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 12)),
        unreadCount: 2,
      ),
      ChatRoomModel(
        id: 'chat_2',
        participants: ['user_1', 'user_3'],
        postId: 'post_2',
        postTitle: 'Brown Leather Wallet',
        postImage: 'https://picsum.photos/seed/chat2/100/100',
        lastMessage: 'Thank you so much! Where can we meet in Dhanmondi?',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages & Chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockChats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final chat = mockChats[index];
          return GlassContainer(
            onTap: () => context.push('/chat/${chat.id}'),
            borderRadius: 18,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(chat.postImage),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chat.postTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    const Text('12:45 PM', style: TextStyle(fontSize: 11, color: AppColors.outline)),
                    const SizedBox(height: 6),
                    if (chat.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Text(
                          '${chat.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
