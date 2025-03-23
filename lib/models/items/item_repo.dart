import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/items/item_model.dart';

class ItemRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<String> addItemToFirestore(ItemModel model) async {
    try {
      DocumentReference docRef = _storage.collection(ItemModel.collectionName).doc();
      await docRef.set(model.toJson()).whenComplete(()
      => print('Item added to Firestore with ID: ${docRef.id}'));
      model.itemID = docRef.id;
      return docRef.id;
    } catch (e) {
      print('Error adding Item to Firestore: $e');
    }
    return "";
  }

  void deleteItemById(String id) async => _storage.collection(ItemModel.collectionName).doc(id).delete();

  Future<bool> updateItem(ItemModel model) async {
    bool isSuccess = false;

    await _storage.collection(ItemModel.collectionName)
        .doc(model.itemID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<ItemModel?> getItemById(String id) async {
    try {
      final DocumentReference<Map<String, dynamic>> collectionRef = _storage.collection(ItemModel.collectionName).doc(id);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await collectionRef.get();

      final ItemModel item = ItemModel.fromJson(documentSnapshot.id, documentSnapshot.data() as Map<String, dynamic>);
      return item;
    } catch (e) {
      return null;
    }

  }

  Future<List<ItemModel>> getTopItems(int limit) async {
    try {
      final QuerySnapshot querySnapshot = await _storage.collection(ItemModel.collectionName)
          .orderBy('addDate', descending: false)
          .limit(limit)
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

  Future<List<ItemModel>> getAllItems() async {
    try {
      final QuerySnapshot querySnapshot = await _storage.collection(ItemModel.collectionName).get();
      final items = querySnapshot
          .docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return items;
    } catch (e) {
      return [];
    }
  }

  Future<List<ItemModel>> getItemsBySeller(String sellerID) async {
    try {
      final QuerySnapshot querySnapshot =
        await _storage.collection(ItemModel.collectionName)
            .where('sellerID', isEqualTo: sellerID)
            .get();

       print("Số lượng tài liệu: ${querySnapshot.docs.length}");
      final items = querySnapshot
          .docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
          
      return items;
    } catch (e) {
      return [];
    }
  }

  Future<List<ItemModel>> getItemsBySearchInput(String searchInput) async {
    try {
      final List<ItemModel> allItems = await getAllItems();
      final List<ItemModel> result = [];

      for (ItemModel item in allItems) {
        if(item.name!.toLowerCase().contains(searchInput.toLowerCase())) {
          result.add(item);
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }

  Future<List<ItemModel>> getRandomItems(int limit) async {
    try {
      final QuerySnapshot querySnapshot = await _storage.collection(ItemModel.collectionName)
          .get();
      List<ItemModel> items = querySnapshot
          .docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      items.shuffle();
      return items.getRange(0, limit).toList();
    } catch (e) {
      return [];
    }
  }
}
