import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/models/shops/shop_model.dart';

class ShopRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<void> addShopToFirestore(ShopModel shop) async {
    try {
      DocumentReference docRef = _storage.collection(ShopModel.collectionName).doc(shop.shopID);
      await docRef.set(shop.toJson()).whenComplete(()
      => debugPrint('Shop added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      debugPrint('Error adding shop to Firestore: $e');
    }
  }

  Future<bool> updateShop(ShopModel model) async {
    bool isSuccess = false;

    await _storage.collection(ShopModel.collectionName)
        .doc(model.shopID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<ShopModel?> getShopById(String id) async {
    try {
      final DocumentReference<Map<String, dynamic>> collectionRef = _storage.collection(ShopModel.collectionName).doc(id);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await collectionRef.get();

      final ShopModel shop = ShopModel.fromJson(documentSnapshot.id, documentSnapshot.data() as Map<String, dynamic>);
      return shop;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }

  }

  Future<List<ShopModel>> getAllShops() async {
    final QuerySnapshot querySnapshot = await _storage.collection(ShopModel.collectionName).get();
    final shops = querySnapshot
        .docs
        .map((doc) => ShopModel.fromJson(doc.id, doc as Map<String, dynamic>))
        .toList();
    return shops;
  }
}