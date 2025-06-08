import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../users/user_model.dart';
import 'message_model.dart';

class ConversationRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<String?> addConversationToFirestore(String userID, ConversationModel model) async {
    try {
      DocumentReference docRef =
      _storage
          .collection(UserModel.collectionName)
          .doc(userID)
          .collection(ConversationModel.collectionName)
          .doc(model.id);
      await docRef.set(model.toJson()).whenComplete(()
      => debugPrint('Conversation added to Firestore with ID: ${docRef.id}'));
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding Conversation to Firestore: $e');
      return null;
    }
  }

  Future<bool> updateConversation(String userID, ConversationModel model) async {
    bool isSuccess = false;

    await _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(ConversationModel.collectionName)
        .doc(model.id)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<ConversationModel?> getConversation(String userID, String conversationID) async {
    try {
      final DocumentReference<Map<String, dynamic>> collectionRef
      = _storage.collection(UserModel.collectionName)
          .doc(userID)
          .collection(ConversationModel.collectionName)
          .doc(conversationID);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await collectionRef.get();

      final ConversationModel model = ConversationModel.fromJson(documentSnapshot.id, documentSnapshot.data() as Map<String, dynamic>);
      return model;
    } catch (e) {
      return null;
    }
  }

  Stream<List<ConversationModel>> getAllConversationStream(String userID) {
    return _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(ConversationModel.collectionName)
        .orderBy('lastActivity', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ConversationModel.fromJson(doc.id, doc.data()))
          .toList();
    });
  }
}