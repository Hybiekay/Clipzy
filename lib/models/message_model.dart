// models/message_model.dart

class MessageModel {
  final String chatId;
  final String lastMessage;
  final String lastSenderId;
  final DateTime? lastTimestamp;
  final String otherUserName;
  final String otherUserImage;
  final String otherUserId;
  final int unreadCount;

  MessageModel({
    required this.chatId,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastTimestamp,
    required this.otherUserName,
    required this.otherUserImage,
    required this.otherUserId,
    required this.unreadCount,
  });
}
