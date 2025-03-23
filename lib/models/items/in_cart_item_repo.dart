import 'package:cloud_firestore/cloud_firestore.dart';

import '../users/user_model.dart';
import 'item_model.dart';

class InCartItemRepo {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  void addItemToUserCart(String userID, ItemModel model) async {
    try {
      DocumentReference docRef
        = _storage.collection(UserModel.collectionName)
                  .doc(userID)
                  .collection(UserModel.cartCollectionName)
                  .doc(model.itemID);
      await docRef.set(model.toJson()).whenComplete(()
      => print('Item added to user $userID \'s Cart with ID: ${docRef.id}'));
    } catch (e) {
      print('Error adding Item to user cart: $e');
    }
  }

  void deleteItemInCart(String userId, String itemId) async
    => _storage.collection(UserModel.collectionName)
              .doc(userId)
              .collection(UserModel.cartCollectionName)
              .doc(itemId)
              .delete();

  Future<bool> updateItemInCart(String userId, ItemModel model) async {
    bool isSuccess = false;

    await _storage.collection(UserModel.collectionName)
        .doc(userId)
        .collection(UserModel.cartCollectionName)
        .doc(model.itemID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<ItemModel> getItemById(String userId, String itemId) async {
    final DocumentReference<Map<String, dynamic>> collectionRef
    = _storage.collection(UserModel.collectionName)
        .doc(userId)
        .collection(UserModel.cartCollectionName)
        .doc(itemId);
    DocumentSnapshot<Map<String, dynamic>> doc = await collectionRef.get();

    final ItemModel item = ItemModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    return item;
  }

  Future<List<ItemModel>> getAllItemsInCart(String userId) async {
    try {
      final QuerySnapshot querySnapshot
        = await _storage.collection(UserModel.collectionName)
                        .doc(userId)
                        .collection(UserModel.cartCollectionName)
                        .get();
      final items = querySnapshot
          .docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return items;
    } catch (e) {
      return [];
    }
  }
}