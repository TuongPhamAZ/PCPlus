import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/models/users/user_model.dart';

class UserRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<void> addUserToFirestore(UserModel user) async {
    try {
      DocumentReference docRef = _storage.collection(UserModel.collectionName).doc(user.userID);
      await docRef.set(user.toJson()).whenComplete(()
      => debugPrint('User added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      debugPrint('Error adding user to Firestore: $e');
    }
  }

  Future<bool> updateUser(UserModel model) async {
    bool isSuccess = false;

    await _storage.collection(UserModel.collectionName)
        .doc(model.userID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final DocumentReference<Map<String, dynamic>> collectionRef = _storage.collection(UserModel.collectionName).doc(id);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await collectionRef.get();

      final UserModel user = UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final QuerySnapshot querySnapshot = await _storage.collection(UserModel.collectionName).get();
    final users = querySnapshot
        .docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    return users;
  }

  Future<List<UserModel>> getAllShops() async {
    final QuerySnapshot querySnapshot = await _storage.collection(UserModel.collectionName)
        .where('isSeller', isEqualTo: true).get();
    final shops = querySnapshot
        .docs
        .map((doc) => UserModel.fromJson(doc as Map<String, dynamic>))
        .toList();
    return shops;
  }

  Future<List<UserModel>> getAllUsersByIdList(List<String> idList) async {
    if (idList.isEmpty) return [];

    // Firestore chỉ cho phép tối đa 10 phần tử trong 'whereIn'
    const int batchSize = 10;
    List<UserModel> users = [];

    for (var i = 0; i < idList.length; i += batchSize) {
      final batchIds = idList.sublist(
        i,
        i + batchSize > idList.length ? idList.length : i + batchSize,
      );

      final querySnapshot = await _storage
          .collection(UserModel.collectionName)
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      final batchUsers = querySnapshot.docs
          // ignore: unnecessary_cast
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      users.addAll(batchUsers);
    }

    return users;
  }

  // Future<String> generateUserID() async {
  //   List<UserModel> users = await getAllUsers();
  //   int count = users.length;
  //   return count.toString().padLeft(8, '0');
  // }

  Stream<UserModel?> getUserByIdStream(String id) {
    final docRef = _storage.collection(UserModel.collectionName).doc(id);

    return docRef.snapshots().map((docSnapshot) {
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return UserModel.fromJson(docSnapshot.data()!);
      } else {
        return null;
      }
    });
  }
}
