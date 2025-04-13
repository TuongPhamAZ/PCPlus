import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:async/async.dart';
import 'package:pcplus/models/users/user_repo.dart';

import '../users/user_model.dart';
import 'item_with_seller.dart';

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

  Future<void> deleteItemById(String id) async => _storage.collection(ItemModel.collectionName).doc(id).delete();

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
          .orderBy('addDate', descending: true)
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

  // STREAM BUILDER

  Stream<List<ItemModel>> getItemsStreamByLargeIdList(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);

    List<Stream<List<ItemModel>>> streams = [];

    for (int i = 0; i < ids.length; i += 10) {
      List<String> subList = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);

      Stream<List<ItemModel>> stream = FirebaseFirestore.instance
          .collection('items')
          .where(FieldPath.documentId, whereIn: subList)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data()))
          .toList());

      streams.add(stream);
    }

    return StreamGroup.merge<List<ItemModel>>(streams).map((list) {
      return list.expand((x) => x as Iterable<ItemModel>).toList();
    });
  }

  Stream<List<ItemModel>> getItemsStreamBySeller(String sellerID) {
    return _storage
        .collection(ItemModel.collectionName)
        .where('sellerID', isEqualTo: sellerID)
        .snapshots()
        .map((snapshot) {
      print("Số lượng tài liệu: ${snapshot.docs.length}");
      return snapshot.docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<ItemModel>> getNewestItemsStream(int limit) {
    return _storage
        .collection(ItemModel.collectionName)
        .orderBy('addDate', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      print("Số lượng tài liệu: ${snapshot.docs.length}");
      return snapshot.docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<ItemWithSeller>> getItemsWithSeller({String searchQuery = ''}) {
    return FirebaseFirestore.instance
        .collection(ItemModel.collectionName)
        .snapshots()
        .asyncMap((itemsSnapshot) async {
      // Lấy danh sách ItemModel
      List<ItemModel> items = itemsSnapshot.docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data()))
          .toList();

      // Lấy danh sách các sellerID (loại bỏ trùng)
      Set<String?> sellerIds = items.map((item) => item.sellerID).toSet();

      // Truy vấn tất cả UserModel cùng lúc
      List<UserModel> sellers = await Future.wait(
        sellerIds.map((id) async {
          return UserRepository().getUserById(id!);
        }),
      );

      // Tạo Map sellerId -> UserModel để tra cứu nhanh
      Map<String, UserModel> sellerMap = {
        for (var seller in sellers.where((s) => s != null)) seller.userID!: seller
      };

      // Ghép dữ liệu UserModel vào ItemModel
      List<ItemWithSeller> itemsWithSeller = items
          .map((item) => ItemWithSeller(item: item, seller: sellerMap[item.sellerID]!))
          .toList();

      // Lọc theo searchQuery
      if (searchQuery.isNotEmpty) {
        String query = searchQuery.toLowerCase(); // Chuyển về lowercase để so sánh
        itemsWithSeller = itemsWithSeller.where((itemWithSeller) {
          return itemWithSeller.item.name!.toLowerCase().contains(query) ||
              itemWithSeller.seller.name!.toLowerCase().contains(query);
        }).toList();
      }

      return itemsWithSeller;
    });
  }

  Stream<List<ItemWithSeller>> getNewestItemsWithSellerStream(int limit) {
    return FirebaseFirestore.instance
        .collection(ItemModel.collectionName)
        .orderBy('addDate', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((itemsSnapshot) async {
      // Lấy danh sách ItemModel
      List<ItemModel> items = itemsSnapshot.docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data()))
          .toList();

      // Lấy danh sách các sellerID (loại bỏ trùng)
      Set<String?> sellerIds = items.map((item) => item.sellerID).toSet();

      // Truy vấn tất cả UserModel cùng lúc
      List<UserModel> sellers = await Future.wait(
        sellerIds.map((id) async {
          return UserRepository().getUserById(id!);
        }),
      );

      // Tạo Map sellerId -> UserModel để tra cứu nhanh
      Map<String, UserModel> sellerMap = {
        for (var seller in sellers.where((s) => s != null)) seller.userID!: seller
      };

      // Ghép dữ liệu UserModel vào ItemModel
      List<ItemWithSeller> itemsWithSeller = items
          .map((item) => ItemWithSeller(item: item, seller: sellerMap[item.sellerID]!))
          .toList();

      return itemsWithSeller;
    });
  }

  Stream<List<ItemWithSeller>> getItemsWithSellerStreamByIdList(List<String> ids) {
    if (ids.isEmpty) return Stream.value([]);

    List<Stream<List<ItemModel>>> streams = [];

    for (int i = 0; i < ids.length; i += 10) {
      List<String> subList = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);

      Stream<List<ItemModel>> stream = FirebaseFirestore.instance
          .collection('items')
          .where(FieldPath.documentId, whereIn: subList)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data()))
          .toList());

      streams.add(stream);
    }

    return StreamGroup.merge<List<ItemModel>>(streams).asyncMap((listOfLists) async {
      // Gộp tất cả ItemModel lại
      final items = listOfLists.expand((x) => x as Iterable<ItemModel>).toList();

      // Lấy danh sách sellerId
      final sellerIds = items.map((item) => item.sellerID).toSet();

      // Lấy thông tin từng seller
      final sellers = await Future.wait(
        sellerIds.map((id) => UserRepository().getUserById(id!)),
      );

      final sellerMap = {
        for (var s in sellers.where((e) => e != null)) s.userID!: s
      };

      // Gắn seller vào từng item
      return items
          .map((item) => ItemWithSeller(
        item: item,
        seller: sellerMap[item.sellerID]!,
      ))
          .toList();
    });
  }

  Stream<List<ItemWithSeller>> getItemsWithSellerStreamBySellerID(String sellerID) {
    return FirebaseFirestore.instance
        .collection(ItemModel.collectionName)
        .where('sellerID', isEqualTo: sellerID)
        .orderBy('addDate', descending: true)
        .snapshots()
        .asyncMap((itemsSnapshot) async {
      // Lấy danh sách ItemModel
      List<ItemModel> items = itemsSnapshot.docs
          .map((doc) => ItemModel.fromJson(doc.id, doc.data()))
          .toList();
      
      // Lấy danh sách các sellerID (loại bỏ trùng)
      Set<String?> sellerIds = items.map((item) => item.sellerID).toSet();

      // Truy vấn tất cả UserModel cùng lúc
      List<UserModel> sellers = await Future.wait(
        sellerIds.map((id) async {
          return UserRepository().getUserById(id!);
        }),
      );

      // Tạo Map sellerId -> UserModel để tra cứu nhanh
      Map<String, UserModel> sellerMap = {
        for (var seller in sellers.where((s) => s != null)) seller.userID!: seller
      };

      // Ghép dữ liệu UserModel vào ItemModel
      List<ItemWithSeller> itemsWithSeller = items
          .map((item) => ItemWithSeller(item: item, seller: sellerMap[item.sellerID]!))
          .toList();

      return itemsWithSeller;
    });
  }
}
