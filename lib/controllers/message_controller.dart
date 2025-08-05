// controllers/message_controller.dart

import 'dart:developer';

import 'package:clipzy/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getUserRecentChats() {
    log("called");
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: authController.user.uid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          List<MessageModel> chatList = [];
          log('this data ${snapshot.docs}');

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final chatId = doc.id;

            final otherUserId = getOtherUserId(
              data['participants'],
              authController.user.uid,
            );

            final otherUserDoc =
                await _firestore.collection('users').doc(otherUserId).get();
            final otherUserData = otherUserDoc.data();

            final unreadQuery =
                await _firestore
                    .collection('chats')
                    .doc(chatId)
                    .collection('messages')
                    .where('senderId', isEqualTo: authController.user.uid)
                    .where('isRead', isEqualTo: false)
                    .get();
            final chat = MessageModel(
              chatId: doc.id,
              lastMessage: data['lastMessage'] ?? '',
              lastSenderId: data['lastSenderId'] ?? '',
              lastTimestamp: (data['lastTimestamp'] as Timestamp?)?.toDate(),
              otherUserName: otherUserData?['name'] ?? '',
              otherUserImage: otherUserData?['profilePhoto'] ?? '',
              otherUserId: otherUserData?['uid'] ?? '',
              unreadCount: unreadQuery.size,
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
