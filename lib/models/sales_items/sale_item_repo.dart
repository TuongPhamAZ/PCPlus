import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/sales_items/sale_item_model.dart';

class SaleItemRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  void addOrderItemToFirestore(SaleItemModel model) async {
    try {
      DocumentReference docRef = _storage.collection(SaleItemModel.collectionName).doc(model.key);
      await docRef.set(model.toJson()).whenComplete(()
      => print('SaleItem added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      print('Error adding SaleItem to Firestore: $e');
    }
  }

  void deleteSaleItemByKey(String key) async => _storage.collection(SaleItemModel.collectionName).doc(key).delete();

  Future<List<SaleItemModel>> getAllSaleItemsBySaleID(String id) async {
    final QuerySnapshot querySnapshot = await _storage.collection(SaleItemModel.collectionName)
        .where('saleID', isEqualTo: id).get();
    final orderItems = querySnapshot
        .docs
        .map((doc) => SaleItemModel.fromJson(doc as Map<String, dynamic>))
        .toList();
    return orderItems;
  }

  Future<List<SaleItemModel>> getAllSaleItemsByItemID(String id) async {
    final QuerySnapshot querySnapshot = await _storage.collection(SaleItemModel.collectionName)
        .where('itemID', isEqualTo: id).get();
    final orderItems = querySnapshot
        .docs
        .map((doc) => SaleItemModel.fromJson(doc as Map<String, dynamic>))
        .toList();
    return orderItems;
  }
}
