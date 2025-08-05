import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipzy/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../controllers/chat_controller.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String userName;
  final String otherUserImage;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.userName,
    required this.otherUserImage,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatController _controller = ChatController();
  final TextEditingController _messageController = TextEditingController();

  String? selectedMessageId;
  String? selectedMessageText;
  bool isEditing = false;

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (isEditing && selectedMessageId != null) {
      _controller.editMessage(
        chatId: widget.chatId,
        messageId: selectedMessageId!,
        newText: text,
      );
      setState(() {
        isEditing = false;
        selectedMessageId = null;
        selectedMessageText = null;
      });
    } else {
      _controller.sendMessage(receiverId: widget.receiverId, text: text);
    }

    _messageController.clear();
  }

  void _startEdit(String id, String currentText) {
    setState(() {
      isEditing = true;
      selectedMessageId = id;
      selectedMessageText = currentText;
      _messageController.text = currentText;
    });
  }

  void _deleteMessage(String id) {
    _controller.deleteMessage(widget.chatId, id);
    setState(() {
      selectedMessageId = null;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: CachedNetworkImageProvider(
                widget.otherUserImage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isEditing ? "Editing..." : widget.userName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions:
            isEditing
                ? [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        isEditing = false;
                        selectedMessageId = null;
                        selectedMessageText = null;
                        _messageController.clear();
                      });
                    },
                  ),
                ]
                : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _controller.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == authController.user.uid;
                    final time = (msg['timestamp'] as Timestamp?)?.toDate();
                    final timeString =
                        time != null ? DateFormat('hh:mm a').format(time) : '';

                    final bubbleColor =
                        isMe
                            ? theme.colorScheme.primary.withOpacity(0.9)
                            : theme.cardColor;

                    final textColor =
                        isMe ? Colors.white : theme.textTheme.bodyLarge?.color;

                    return GestureDetector(
                      onLongPress: () {
                        if (isMe) {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder:
                                (_) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text("Edit"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _startEdit(msg.id, msg['text']);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text("Delete"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _deleteMessage(msg.id);
                                      },
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment:
                            isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment:
                                  isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 220,
                                    minWidth: 70,
                                  ),

                                  margin: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bubbleColor,
                                    borderRadius: BorderRadius.circular(
                                      15,
                                    ).copyWith(
                                      bottomRight: Radius.circular(
                                        isMe ? 0 : 15,
                                      ),
                                      bottomLeft: Radius.circular(
                                        isMe ? 15 : 0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    msg['text'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 2),
                                Text(
                                  timeString,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe ? Colors.white70 : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              offset: const Offset(0, -1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText:
                      isEditing ? "Edit your message..." : "Type a message...",
                  fillColor:
                      theme.inputDecorationTheme.fillColor ??
                      theme.colorScheme.surfaceVariant,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primary,
                radius: 22,
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
