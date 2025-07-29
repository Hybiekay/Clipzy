// controllers/message_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class MessageController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getUserRecentChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }
}
