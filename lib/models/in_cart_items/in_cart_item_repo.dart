import 'package:cloud_firestore/cloud_firestore.dart';

import '../users/user_model.dart';
import 'in_cart_item_model.dart';

class InCartItemRepo {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<String?> addItemToUserCart(String userID, InCartItemModel model) async {
    try {
      DocumentReference docRef
        = _storage.collection(UserModel.collectionName)
                  .doc(userID)
                  .collection(UserModel.cartCollectionName)
                  .doc();
      await docRef.set(model.toJson()).whenComplete(()
      => print('Item ${model.itemID} added to user $userID \'s Cart with ID: ${docRef.id}'));
      return docRef.id;
    } catch (e) {
      print('Error adding Item to user cart: $e');
      return null;
    }
  }

  void deleteItemInCart(String userId, InCartItemModel model) async
    => _storage.collection(UserModel.collectionName)
              .doc(userId)
              .collection(UserModel.cartCollectionName)
              .doc(model.key)
              .delete();

  Future<bool> updateItemInCart(String userId, InCartItemModel model) async {
    bool isSuccess = false;

    await _storage.collection(UserModel.collectionName)
        .doc(userId)
        .collection(UserModel.cartCollectionName)
        .doc(model.key)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  // Future<ItemModel> getItemById(String userId, String itemId) async {
  //   final DocumentReference<Map<String, dynamic>> collectionRef
  //   = _storage.collection(UserModel.collectionName)
  //       .doc(userId)
  //       .collection(UserModel.cartCollectionName)
  //       .doc(itemId);
  //   DocumentSnapshot<Map<String, dynamic>> doc = await collectionRef.get();
  //
  //   final ItemModel item = ItemModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  //   return item;
  // }

  Future<List<InCartItemModel>> getAllItemsInCart(String userId) async {
    try {
      final QuerySnapshot querySnapshot
        = await _storage.collection(UserModel.collectionName)
                        .doc(userId)
                        .collection(UserModel.cartCollectionName)
                        .get();
      final items = querySnapshot
          .docs
          .map((doc) => InCartItemModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return items;
    } catch (e) {
      return [];
    }
  }
}