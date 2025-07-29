// controllers/message_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getUserRecentChats(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<MessageModel> chatList = [];

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final otherUserId = getOtherUserId(
              data['participants'],
              currentUserId,
            );

            final otherUserDoc =
                await _firestore.collection('users').doc(otherUserId).get();
            final otherUserData = otherUserDoc.data();

            final chat = MessageModel(
              chatId: doc.id,
              lastMessage: data['lastMessage'] ?? '',
              lastSenderId: data['lastSenderId'] ?? '',
              lastTimestamp: (data['lastTimestamp'] as Timestamp?)?.toDate(),
              otherUserName: otherUserData?['name'] ?? '',
              otherUserImage: otherUserData?['profileImage'] ?? '',
            );

            chatList.add(chat);
          }

          return chatList;
        });
  }

  String getOtherUserId(List<dynamic> participants, String currentUserId) {
    return participants.firstWhere((id) => id != currentUserId);
  }
}
