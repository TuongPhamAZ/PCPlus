import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/models/orders/order_model.dart';
import 'package:pcplus/models/system/param_store_repo.dart';
import '../users/user_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class OrderRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  void addOrderToFirestore(String userID, OrderModel model) async {
    try {
      DocumentReference docRef =
        _storage.collection(UserModel.collectionName)
                .doc(userID)
                .collection(OrderModel.collectionName)
                .doc(model.orderID);
      await docRef.set(model.toJson()).whenComplete(()
      => debugPrint('Order added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      debugPrint('Error adding Order to Firestore: $e');
    }
  }

  Future<bool> updateOrder(String userID, OrderModel model) async {
    bool isSuccess = false;

    await _storage.collection(UserModel.collectionName)
        .doc(userID)
        .collection(OrderModel.collectionName)
        .doc(model.orderID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<List<OrderModel>> getAllOrdersFromUser(String userID) async {
    try {
      final QuerySnapshot querySnapshot =
        await _storage.collection(UserModel.collectionName)
            .doc(userID)
            .collection(OrderModel.collectionName)
            .get();
      final orders = querySnapshot
          .docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return orders;
    } catch (e) {
      return [];
    }
  }

  Future<List<OrderModel>> getAllOrdersFromUserByStatus(String userID, String status) async {
    try {
      final QuerySnapshot querySnapshot =
      await _storage.collection(UserModel.collectionName)
          .doc(userID)
          .collection(OrderModel.collectionName)
          .where('status', isEqualTo: status)
          .orderBy('orderDate', descending: true)
          .get();
      final orders = querySnapshot
          .docs
          .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return orders;
    } catch (e) {
      return [];
    }
  }

  Stream<List<OrderModel>> getAllOrdersFromUserStream(String userID) {
    return _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(OrderModel.collectionName)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<List<OrderModel>> getAllOrdersFromUserByStatusStream(String userID, String status) {
    return _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(OrderModel.collectionName)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .toList();
    });
  }

  Future<String?> generateID() async {
    ParamStoreRepository paramStoreRepository = ParamStoreRepository();
    final int id = await paramStoreRepository.getOrderIdIndex();
    const prefix = "PCP";

    return "$prefix${(id).toString().padLeft(10, '0')}";
  }
}
