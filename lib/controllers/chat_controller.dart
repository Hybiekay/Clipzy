// controllers/chat_controller.dart

import 'package:clipzy/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final senderId = authController.user.uid;

    final chatId = generateChatId(senderId, receiverId);
    final chatRef = _firestore.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    final timestamp = FieldValue.serverTimestamp();

    await _firestore.runTransaction((transaction) async {
      final chatSnapshot = await transaction.get(chatRef);

      // If chat doesn't exist, initialize it
      if (!chatSnapshot.exists) {
        transaction.set(chatRef, {
          'participants': [senderId, receiverId],
          'lastMessage': text,
          'lastSenderId': senderId,
          'lastTimestamp': timestamp,
        });
      } else {
        transaction.update(chatRef, {
          'lastMessage': text,
          'lastSenderId': senderId,
          'lastTimestamp': timestamp,
        });
      }

      // Add the message to messages subcollection
      transaction.set(messageRef, {
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'timestamp': timestamp,
        "isRead": false, // 👈 New field
      });
    });
  }

  void markMessagesAsRead(String chatId, String currentUserId) {
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    messagesRef
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({'isRead': true});
          }
        });
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> editMessage({
    required String chatId,
    required String messageId,
    required String newText,
  }) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'text': newText});
  }

  String generateChatId(String id1, String id2) {
    return (id1.compareTo(id2) < 0) ? "$id1\_$id2" : "$id2\_$id1";
  }
}
