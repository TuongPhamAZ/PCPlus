import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/models/ratings/rating_model.dart';
import 'package:pcplus/models/ratings/rating_with_user.dart';
import 'package:pcplus/services/utility.dart';
import 'package:async/async.dart';
import '../items/item_model.dart';
import '../users/user_model.dart';

class RatingRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<void> addRatingToFirestore(String itemID, RatingModel model) async {
    try {
      DocumentReference docRef =
        _storage.collection(ItemModel.collectionName)
            .doc(model.itemID)
            .collection(RatingModel.collectionName)
            .doc();
      await docRef.set(model.toJson()).whenComplete(()
      => debugPrint('Rating added to Firestore with ID: ${docRef.id}'));
      model.itemID = docRef.id;
    } catch (e) {
      debugPrint('Error adding Rating to Firestore: $e');
    }
  }

  void deleteRatingById(String itemId, String ratingId) async
    => _storage.collection(ItemModel.collectionName)
          .doc(itemId)
          .collection(RatingModel.collectionName)
          .doc(ratingId)
          .delete();

  Future<bool> updateRating(RatingModel model) async {
    bool isSuccess = false;

    await _storage.collection(ItemModel.collectionName)
        .doc(model.itemID)
        .collection(RatingModel.collectionName)
        .doc(model.key)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<RatingModel> getRatingByKey(String itemID, String key) async {
    final DocumentReference<Map<String, dynamic>> collectionRef
      = _storage.collection(ItemModel.collectionName)
          .doc(itemID)
          .collection(RatingModel.collectionName)
          .doc(key);
    DocumentSnapshot<Map<String, dynamic>> doc = await collectionRef.get();

    final RatingModel item = RatingModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    return item;
  }

  Future<List<RatingModel>> getAllRatingsByItemID(String itemId) async {
    try {
      final QuerySnapshot querySnapshot =
        await _storage.collection(ItemModel.collectionName)
          .doc(itemId)
          .collection(RatingModel.collectionName)
          .get();
      final items = querySnapshot
          .docs
          .map((doc) => RatingModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return items;
    } catch (e) {
      return [];
    }
  }

  Future<double> getRatingValueByItemID(String itemId) async {
    try {
      final QuerySnapshot querySnapshot =
        await _storage.collection(ItemModel.collectionName)
                .doc(itemId)
                .collection(RatingModel.collectionName)
                .get();
      final items = querySnapshot
          .docs
          .map((doc) => RatingModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      if (items.isEmpty) {
        return 0;
      }
      double rating = 0;
      for (RatingModel item in items) {
        rating += item.rating!;
      }
      rating = rating / items.length;
      String ratingText = Utility.formatRatingValue(rating);
      return double.parse(ratingText);
    } catch (e) {
      debugPrint(e as String?);
      return 0;
    }
  }

  Stream<List<RatingModel>> getUserRatingsStream(String userID) async* {
    final itemSnapshot = await FirebaseFirestore.instance
        .collection(ItemModel.collectionName)
        .get();

    // Tạo list stream từ mỗi subcollection 'ratings'
    List<Stream<List<RatingModel>>> streams = itemSnapshot.docs.map((itemDoc) {
      return FirebaseFirestore.instance
          .collection(ItemModel.collectionName)
          .doc(itemDoc.id)
          .collection(RatingModel.collectionName)
          .where('userID', isEqualTo: userID)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) =>
          RatingModel.fromJson(doc.id, doc.data()))
          .toList());
    }).toList();

    // Gộp tất cả stream lại thành một stream duy nhất
    yield* StreamGroup.merge<List<RatingModel>>(streams).map((list) {
      return list.expand((x) => x as Iterable<RatingModel>).toList();
    });
  }

  Stream<List<RatingWithUser>> getAllRatingWithUserByItemID(String itemId) {
    final ratingRef = FirebaseFirestore.instance
        .collection(ItemModel.collectionName)
        .doc(itemId)
        .collection(RatingModel.collectionName);

    // Lắng nghe mọi thay đổi trong subcollection ratings
    return ratingRef.snapshots().asyncMap((querySnapshot) async {
      final ratingDocs = querySnapshot.docs;

      // Lấy toàn bộ RatingModel
      final ratings = ratingDocs.map((doc) {
        return RatingModel.fromJson(doc.id, doc.data());
      }).toList();

      // Với mỗi rating, lấy UserModel tương ứng
      final futures = ratings.map((rating) async {
        try {
          final userSnap = await FirebaseFirestore.instance
              .collection(UserModel.collectionName)
              .doc(rating.userID)
              .get();

          final user = UserModel.fromJson(userSnap.data()!);

          return RatingWithUser(rating: rating, user: user);
        } catch (e) {
          // fallback nếu không lấy được user
          return null;
        }
      }).toList();

      // Chờ tất cả tương lai hoàn thành, và lọc null
      final result = await Future.wait(futures);
      return result.whereType<RatingWithUser>().toList();
    });
  }
}
