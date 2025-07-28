// models/message_model.dart

class MessageModel {
  final String id;
  final String senderName;
  final String lastMessage;
  final String timestamp;
  final String senderAvatarUrl;

  MessageModel({
    required this.id,
    required this.senderName,
    required this.lastMessage,
    required this.timestamp,
    required this.senderAvatarUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data, String docId) {
    return MessageModel(
      id: docId,
      senderName: data['senderName'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      timestamp: data['timestamp'] ?? '',
      senderAvatarUrl: data['senderAvatarUrl'] ?? '',
    );
  }
}
