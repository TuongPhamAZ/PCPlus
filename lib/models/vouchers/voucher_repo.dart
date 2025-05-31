import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/models/vouchers/voucher_model.dart';

import '../shops/shop_model.dart';

class VoucherRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<String?> addVoucherToFirestore(String shopID, VoucherModel model) async {
    try {
      DocumentReference docRef =
      _storage.collection(ShopModel.collectionName)
          .doc(shopID)
          .collection(VoucherModel.collectionName)
          .doc();
      await docRef.set(model.toJson()).whenComplete(()
      => debugPrint('Voucher added to Firestore with ID: ${docRef.id}'));
      model.voucherID = docRef.id;
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding Rating to Firestore: $e');
      return null;
    }
  }

  Future<void> deleteVoucherById(String shopId, String ratingId) async
  => _storage.collection(ShopModel.collectionName)
          .doc(shopId)
          .collection(VoucherModel.collectionName)
          .doc(ratingId)
          .delete();

  Future<bool> updateVoucher(String shopID, VoucherModel model) async {
    bool isSuccess = false;

    await _storage.collection(ShopModel.collectionName)
        .doc(shopID)
        .collection(VoucherModel.collectionName)
        .doc(model.voucherID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<VoucherModel?> getVoucherByID(String shopID, String voucherID) async {
    try {
      final DocumentReference<Map<String, dynamic>> collectionRef
      = _storage.collection(ShopModel.collectionName)
          .doc(shopID)
          .collection(VoucherModel.collectionName)
          .doc(voucherID);
      DocumentSnapshot<Map<String, dynamic>> doc = await collectionRef.get();

      final VoucherModel? item = VoucherModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      return item;
    } catch (e) {
      return null;
    }
  }

  Stream<List<VoucherModel>> getShopVouchersStream(String shopID) async* {
    final itemSnapshot = await FirebaseFirestore.instance
        .collection(ShopModel.collectionName)
        .get();

    // Tạo list stream từ mỗi subcollection 'vouchers'
    List<Stream<List<VoucherModel>>> streams = itemSnapshot.docs.map((itemDoc) {
      return FirebaseFirestore.instance
          .collection(ShopModel.collectionName)
          .doc(itemDoc.id)
          .collection(VoucherModel.collectionName)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => VoucherModel.fromJson(doc.id, doc.data())!)
          .toList());
    }).toList();

    // Gộp tất cả stream lại thành một stream duy nhất
    yield* StreamGroup.merge<List<VoucherModel>>(streams).map((list) {
      return list.expand((x) => x as Iterable<VoucherModel>).toList();
    });
  }

}