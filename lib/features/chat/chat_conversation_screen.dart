import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/chat_model.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final String id;

  const ChatConversationScreen({super.key, required this.id});

  @override
  ConsumerState<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends ConsumerState<ChatConversationScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      id: 'm1',
      senderId: 'other',
      text: 'Hello! I saw your report for the lost iPhone near Banani.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ChatMessageModel(
      id: 'm2',
      senderId: 'me',
      text: 'Hi! Yes, did you find it?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    ChatMessageModel(
      id: 'm3',
      senderId: 'other',
      text: 'Yes! It matches your description. Where can we meet in Dhanmondi?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'me',
        text: text,
        timestamp: DateTime.now(),
      ));
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Naimur Rahman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Online • Verified Member', style: TextStyle(fontSize: 11, color: Colors.green)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.phone_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg.senderId == 'me';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        fontSize: 14,
                      ),
                    ),
                  ),
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
                    onPressed: () {},
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
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
