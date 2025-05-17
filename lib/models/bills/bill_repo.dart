import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/system/param_store_repo.dart';

import '../users/user_model.dart';
import 'bill_model.dart';

class BillRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<void> addBillToFirestore(String userID, BillModel model) async {
    try {
      DocumentReference docRef =
      _storage.collection(UserModel.collectionName)
          .doc(userID)
          .collection(BillModel.collectionName)
          .doc(model.billID);
      await docRef.set(model.toJson()).whenComplete(()
      => print('Bill added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      print('Error adding Bill to Firestore: $e');
    }
  }

  Future<BillModel?> getBill(String userID, String billID) async {
    try {
      final DocumentReference<Map<String, dynamic>> collectionRef
        = _storage.collection(UserModel.collectionName)
                  .doc(userID)
                  .collection(BillModel.collectionName)
                  .doc(billID);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await collectionRef.get();

      final BillModel model = BillModel.fromJson(documentSnapshot.id, documentSnapshot.data() as Map<String, dynamic>);
      return model;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateBill(String userID, BillModel model) async {
    bool isSuccess = false;

    await _storage.collection(UserModel.collectionName)
        .doc(userID)
        .collection(BillModel.collectionName)
        .doc(model.billID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Stream<List<BillModel>> getAllBillsFromUserStream(String userID) {
    return _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(BillModel.collectionName)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BillModel.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  // Stream<List<BillModel>> getAllBillsFromUserByStatusStream(String userID, String status) {
  //   return _storage
  //       .collection(UserModel.collectionName)
  //       .doc(userID)
  //       .collection(BillModel.collectionName)
  //       .where('status', isEqualTo: status)
  //       .snapshots()
  //       .map((snapshot) {
  //     return snapshot.docs
  //         .map((doc) => BillModel.fromJson(doc.id, doc.data()))
  //         .toList();
  //   });
  // }

  Future<String?> generateID() async {
    ParamStoreRepository paramStoreRepository = ParamStoreRepository();
    final int id = await paramStoreRepository.getOrderIdIndex();
    const prefix = "PCP";

    return "$prefix${(id).toString().padLeft(10, '0')}";
  }
}
