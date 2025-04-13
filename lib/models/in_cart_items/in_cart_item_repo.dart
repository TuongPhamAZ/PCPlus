import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../items/item_model.dart';
import '../users/user_model.dart';
import '../users/user_repo.dart';
import 'in_cart_item_model.dart';
import 'item_in_cart_with_seller.dart';

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

  Future<void> deleteItemInCart(String userId, InCartItemModel model) async
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

  Future<InCartItemModel?> getItemInCartByItemID(String userId, String itemId) async {
    final querySnapshot = await _storage
        .collection(UserModel.collectionName)
        .doc(userId)
        .collection(UserModel.cartCollectionName)
        .where('itemID', isEqualTo: itemId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null; // không tìm thấy
    }

    final doc = querySnapshot.docs.first;

    return InCartItemModel.fromJson(doc.id, doc.data());
  }

  Future<void> selectAllItemInCart(String userId, bool isSelected) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Bước 1: Lấy toàn bộ documents trong collection
    final querySnapshot = await _storage.collection(UserModel.collectionName)
                                        .doc(userId)
                                        .collection(UserModel.cartCollectionName)
                                        .get();

    // Bước 2: Lặp qua từng document và thêm vào batch
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isSelected': isSelected});
    }

    // Bước 3: Commit batch
    await batch.commit();
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

  // Stream<List<InCartItemModel>> getAllSelectedItemsInCarts(String userId) {
  //   return _storage
  //       .collection(UserModel.collectionName)
  //       .doc(userId)
  //       .collection(UserModel.cartCollectionName)
  //       .snapshots()
  //       .map((querySnapshot) {
  //     return querySnapshot.docs
  //         .map((doc) => InCartItemModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
  //         .toList();
  //   });
  // }

  Stream<List<ItemInCartWithSeller>> getAllItemsInCartStream(String userId) {
    final cartStream = FirebaseFirestore.instance
        .collection(UserModel.collectionName)
        .doc(userId)
        .collection(UserModel.cartCollectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => InCartItemModel.fromJson(doc.id, doc.data()))
        .toList());

    final itemStream = FirebaseFirestore.instance
        .collection(ItemModel.collectionName)
        .snapshots()
        .asyncMap((itemsSnapshot) async {
      List<ItemModel> items = itemsSnapshot.docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data()))
          .toList();

      Set<String?> sellerIds = items.map((item) => item.sellerID).toSet();
      List<UserModel> sellers = await Future.wait(
        sellerIds.map((id) => UserRepository().getUserById(id!)),
      );

      Map<String, UserModel> sellerMap = {
        for (var seller in sellers.where((s) => s != null)) seller.userID!: seller
      };

      return {
        'items': items,
        'sellerMap': sellerMap,
      };
    });

    return Rx.combineLatest2(
      cartStream,
      itemStream,
          (List<InCartItemModel> cartItems, dynamic itemData) {
        List<ItemModel> items = itemData['items'];
        Map<String, UserModel> sellerMap = itemData['sellerMap'];

        Map<String, ItemModel> itemMap = {
          for (var item in items) item.itemID!: item
        };

        return cartItems
            .map((cartItem) {
          final item = itemMap[cartItem.itemID];
          final seller = item != null ? sellerMap[item.sellerID] : null;
          if (item != null && seller != null) {
            return ItemInCartWithSeller(
              item: item,
              seller: seller,
              inCart: cartItem,
            );
          }
          return null;
        })
            .whereType<ItemInCartWithSeller>() // remove nulls
            .toList();
      },
    );
  }

  Stream<List<ItemInCartWithSeller>> getAllSelectedItemsInCartStream(String userId) {
    final cartStream = FirebaseFirestore.instance
        .collection(UserModel.collectionName)
        .doc(userId)
        .collection(UserModel.cartCollectionName)
        .where("isSelected", isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => InCartItemModel.fromJson(doc.id, doc.data()))
        .toList());

    final itemStream = FirebaseFirestore.instance
        .collection(ItemModel.collectionName)
        .snapshots()
        .asyncMap((itemsSnapshot) async {
      List<ItemModel> items = itemsSnapshot.docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data()))
          .toList();

      Set<String?> sellerIds = items.map((item) => item.sellerID).toSet();
      List<UserModel> sellers = await Future.wait(
        sellerIds.map((id) => UserRepository().getUserById(id!)),
      );

      Map<String, UserModel> sellerMap = {
        for (var seller in sellers.where((s) => s != null)) seller.userID!: seller
      };

      return {
        'items': items,
        'sellerMap': sellerMap,
      };
    });

    return Rx.combineLatest2(
      cartStream,
      itemStream,
          (List<InCartItemModel> cartItems, dynamic itemData) {
        List<ItemModel> items = itemData['items'];
        Map<String, UserModel> sellerMap = itemData['sellerMap'];

        Map<String, ItemModel> itemMap = {
          for (var item in items) item.itemID!: item
        };

        return cartItems
            .map((cartItem) {
          final item = itemMap[cartItem.itemID];
          final seller = item != null ? sellerMap[item.sellerID] : null;
          if (item != null && seller != null) {
            return ItemInCartWithSeller(
              item: item,
              seller: seller,
              inCart: cartItem,
            );
          }
          return null;
        })
            .whereType<ItemInCartWithSeller>() // remove nulls
            .toList();
      },
    );
  }
}