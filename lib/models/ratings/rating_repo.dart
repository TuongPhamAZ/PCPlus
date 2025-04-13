import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/ratings/rating_model.dart';
import 'package:pcplus/services/utility.dart';
import 'package:async/async.dart';
import '../items/item_model.dart';

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
      => print('Rating added to Firestore with ID: ${docRef.id}'));
      model.itemID = docRef.id;
    } catch (e) {
      print('Error adding Rating to Firestore: $e');
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
      print(e);
      return 0;
    }
  }

  Stream<List<RatingModel>> getUserRatingsStream(String userID) async* {
    final itemSnapshot = await FirebaseFirestore.instance
        .collection('items')
        .get();

    // Tạo list stream từ mỗi subcollection 'ratings'
    List<Stream<List<RatingModel>>> streams = itemSnapshot.docs.map((itemDoc) {
      return FirebaseFirestore.instance
          .collection('items')
          .doc(itemDoc.id)
          .collection('ratings')
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

}
