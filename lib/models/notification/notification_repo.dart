import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/orders/order_model.dart';
import 'package:pcplus/models/system/param_store_model.dart';
import 'package:pcplus/models/system/param_store_repo.dart';

import '../../services/utility.dart';
import '../users/user_model.dart';
import 'notification_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class NotificationRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  void addNotificationToFirestore(String userID, NotificationModel model) async {
    try {
      DocumentReference docRef =
      _storage.collection(UserModel.collectionName)
          .doc(userID)
          .collection(NotificationModel.collectionName)
          .doc();
      await docRef.set(model.toJson()).whenComplete(()
      => print('Notification added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      print('Error adding Order to Firestore: $e');
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

  Future<List<NotificationModel>> getAllNotificationsFromUser(String userID) async {
    try {
      final QuerySnapshot querySnapshot =
      await _storage.collection(UserModel.collectionName)
          .doc(userID)
          .collection(NotificationModel.collectionName)
          .orderBy('date')
          .get();
      final models = querySnapshot
          .docs
          .map((doc) => NotificationModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return models;
    } catch (e) {
      return [];
    }
  }
}
