import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/system/param_store_repo.dart';

import '../shops/shop_model.dart';
import 'bill_of_shop_model.dart';

class BillOfShopRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<void> addBillOfShopToFirestore(String shopID, BillOfShopModel model) async {
    try {
      DocumentReference docRef =
      _storage.collection(ShopModel.collectionName)
          .doc(shopID)
          .collection(BillOfShopModel.collectionName)
          .doc(model.billID);
      await docRef.set(model.toJson()).whenComplete(()
      => print('Bill of Shop added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      print('Error adding Bill of Shop to Firestore: $e');
    }
  }

  Future<bool> updateBillOfShop(String shopID, BillOfShopModel model) async {
    bool isSuccess = false;

    await _storage.collection(ShopModel.collectionName)
        .doc(shopID)
        .collection(BillOfShopModel.collectionName)
        .doc(model.billID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Stream<List<BillOfShopModel>> getAllBillsOfShopFromShopStream(String shopID) {
    return _storage
        .collection(ShopModel.collectionName)
        .doc(shopID)
        .collection(BillOfShopModel.collectionName)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BillOfShopModel.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<BillOfShopModel>> getAllBillsOfShopFromShopByStatusStream(String ShopID, String status) {
    return _storage
        .collection(ShopModel.collectionName)
        .doc(ShopID)
        .collection(BillOfShopModel.collectionName)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BillOfShopModel.fromJson(doc.id, doc.data()))
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
