import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../shops/shop_model.dart';
import '../users/user_model.dart';
import 'message_model.dart';

class MessageRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<String?> addMessageToFirestore(String userID, String conversationID, MessageModel model) async {
    try {
      DocumentReference docRef =
      _storage
          .collection(UserModel.collectionName)
          .doc(userID)
          .collection(ConversationModel.collectionName)
          .doc(conversationID)
          .collection(MessageModel.collectionName)
          .doc(model.id);

      model.id = docRef.id;
      await docRef.set(model.toJson()).whenComplete(()
      => debugPrint('Message added to Firestore with ID: ${docRef.id}'));
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding Message to Firestore: $e');
      return null;
    }
  }

  Future<bool> updateMessage(String userID, String conversationID, MessageModel model) async {
    bool isSuccess = false;

    await _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(ConversationModel.collectionName)
        .doc(conversationID)
        .collection(MessageModel.collectionName)
        .doc(model.id)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Stream<List<MessageModel>> getAllMessagesStream(String userID, String conversationID) {
    return _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(ConversationModel.collectionName)
        .doc(conversationID)
        .collection(MessageModel.collectionName)
        .orderBy('time', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();
    });
  }
}