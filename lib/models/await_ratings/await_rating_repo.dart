import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/system/param_store_repo.dart';

import '../shops/shop_model.dart';
import '../users/user_model.dart';
import 'await_rating_model.dart';

class AwaitRatingRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<void> addAwaitRatingToFirestore(String userID, AwaitRatingModel model) async {
    try {
      DocumentReference docRef =
      _storage.collection(UserModel.collectionName)
          .doc(userID)
          .collection(AwaitRatingModel.collectionName)
          .doc();
      await docRef.set(model.toJson()).whenComplete(()
      => print('AwaitRating added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      print('Error adding AwaitRating to Firestore: $e');
    }
  }

  Future<bool> updateAwaitRating(String userID, AwaitRatingModel model) async {
    bool isSuccess = false;

    await _storage.collection(UserModel.collectionName)
        .doc(userID)
        .collection(AwaitRatingModel.collectionName)
        .doc(model.key)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<void> deleteAwaitRatingByKey(String userID, String key) async =>
      _storage.collection(UserModel.collectionName)
      .doc(userID)
      .collection(AwaitRatingModel.collectionName)
      .doc(key)
      .delete();

  Future<List<AwaitRatingModel>> getAllAwaitRating(String userID) async {
     try {
       final QuerySnapshot querySnapshot = await _storage
           .collection(UserModel.collectionName)
           .doc(userID)
           .collection(AwaitRatingModel.collectionName)
           .orderBy('createdAt', descending: true)
           .get();

       final items = querySnapshot
           .docs
           .map((doc) => AwaitRatingModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
           .toList();
       return items;
     } catch (e) {
       return [];
     }
  }

  Stream<List<AwaitRatingModel>> getAllAwaitRatingStream(String userID) {
    return _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(AwaitRatingModel.collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AwaitRatingModel.fromJson(doc.id, doc.data()))
          .toList();
    });
  }
}
