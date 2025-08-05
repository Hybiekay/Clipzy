// views/messages/chat_detail_screen.dart

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
    return Scaffold(
      appBar: AppBar(
        leading: CircleAvatar(
          radius: 26,
          backgroundImage: CachedNetworkImageProvider(widget.otherUserImage),
        ),
        title: Text(isEditing ? "Edit Message" : widget.userName),
        centerTitle: true,
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
                    vertical: 20,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == authController.user.uid;
                    final time = (msg['timestamp'] as Timestamp?)?.toDate();
                    final timeString =
                        time != null ? DateFormat('hh:mm a').format(time) : '';

                    return GestureDetector(
                      onLongPress: () {
                        if (isMe) {
                          showModalBottomSheet(
                            context: context,
                            builder:
                                (_) => Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Wrap(
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
                                ),
                          );
                        }
                      },
                      child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text'],
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeString,
                                style: TextStyle(
                                  color:
                                      isMe ? Colors.white70 : Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText:
                      isEditing ? "Edit message..." : "Type your message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
