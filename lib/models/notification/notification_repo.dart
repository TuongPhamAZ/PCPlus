import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../users/user_model.dart';
import 'notification_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class NotificationRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addNotificationToFirestore(String userID, NotificationModel model) async {
    try {
      DocumentReference docRef =
      _storage.collection(UserModel.collectionName)
          .doc(userID)
          .collection(NotificationModel.collectionName)
          .doc();
      await docRef.set(model.toJson()).whenComplete(()
      => debugPrint('Notification added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      debugPrint('Error adding Order to Firestore: $e');
    }
  }

  Future<bool> updateNotification(String userID, NotificationModel model) async {
    bool isSuccess = false;

    await _storage.collection(UserModel.collectionName)
        .doc(userID)
        .collection(NotificationModel.collectionName)
        .doc(model.key)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Stream<List<NotificationModel>> getAllNotificationsFromUserStream(String userID) {
    return _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(NotificationModel.collectionName)
        .orderBy('date', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          // ignore: unnecessary_cast
          .map((doc) => NotificationModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}
