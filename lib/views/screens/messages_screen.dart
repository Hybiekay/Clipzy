import 'package:clipzy/constants.dart';
import 'package:clipzy/views/screens/user_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:badges/badges.dart' as badges;
import '../../../controllers/message_controller.dart';
import '../../../models/message_model.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends StatelessWidget {
  final MessageController _controller = MessageController();

  MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<MessageModel>>(
        stream: _controller.getUserRecentChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No recent messages"));
          }

          final messages = snapshot.data!;

          return ListView.separated(
            itemCount: messages.length,
            separatorBuilder: (_, __) => const Divider(indent: 70),
            itemBuilder: (context, index) {
              final msg = messages[index];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                leading: badges.Badge(
                  showBadge: msg.unreadCount > 0,
                  position: badges.BadgePosition.topEnd(top: -5, end: -5),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
                  badgeContent: Text(
                    msg.unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(msg.otherUserImage),
                  ),
                ),
                title: Text(
                  msg.otherUserName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  msg.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                trailing: Text(
                  formatTime(msg.lastTimestamp),
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatDetailScreen(
                            userName: msg.otherUserName,
                            chatId: msg.chatId,
                            receiverId: msg.otherUserId,
                            otherUserImage: msg.otherUserImage,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: buttonColor,
        child: const Icon(Ionicons.chatbubble_outline),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserListScreen()),
          );
        },
      ),
    );
  }

  String formatTime(DateTime? time) {
    if (time == null) return "";
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return "${time.day}/${time.month}/${time.year}";
  }
}
