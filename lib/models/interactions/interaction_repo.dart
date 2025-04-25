import 'package:cloud_firestore/cloud_firestore.dart';

import 'interaction_model.dart';

class InteractionRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  void addInteractionToFirestore(InteractionModel model) async {
    try {
      DocumentReference docRef = _storage.collection(InteractionModel.collectionName).doc(model.itemID);
      await docRef.set(model.toJson()).whenComplete(()
      => print('Interaction added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      print('Error adding Interaction to Firestore: $e');
    }
  }

  void deleteInteractionByKey(String key) async => _storage.collection(InteractionModel.collectionName).doc(key).delete();

  Future<bool> updateInteraction(InteractionModel model) async {
    bool isSuccess = false;

    await _storage.collection(InteractionModel.collectionName)
        .doc(model.itemID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<InteractionModel> getInteractionsByUserIDAndItemID(String userID, String itemID) async {
    final QuerySnapshot querySnapshot = await _storage.collection(InteractionModel.collectionName)
        .where('userID', isEqualTo: userID)
        .where('itemID', isEqualTo: itemID)
        .get();
    final items = querySnapshot
        .docs
        .map((doc) => InteractionModel.fromJson(doc.id, doc as Map<String, dynamic>))
        .toList();
    return items.first;
  }

  Future<List<InteractionModel>> getAllInteractionsByUserID(String id) async {
    final QuerySnapshot querySnapshot = await _storage.collection(InteractionModel.collectionName)
        .where('userID', isEqualTo: id).get();
    final items = querySnapshot
        .docs
        .map((doc) => InteractionModel.fromJson(doc.id, doc as Map<String, dynamic>))
        .toList();
    return items;
  }

  Future<int> getSoldCountByItemID(String id) async {
    final QuerySnapshot querySnapshot = await _storage.collection(InteractionModel.collectionName)
        .where('itemID', isEqualTo: id).get();
    final items = querySnapshot
        .docs
        .map((doc) => InteractionModel.fromJson(doc.id, doc as Map<String, dynamic>))
        .toList();
    int count = 0;
    for (InteractionModel item in items) {
      count = item.buyTimes!;
    }
    return count;
  }

  Future<double> getRatingByItemID(String id) async {
    try {
      final QuerySnapshot querySnapshot = await _storage.collection(InteractionModel.collectionName)
          .where('itemID', isEqualTo: id).get();
      final items = querySnapshot
          .docs
          .map((doc) => InteractionModel.fromJson(doc.id, doc as Map<String, dynamic>))
          .toList();
      if (items.isEmpty) {
        return 0;
      }
      double rating = 0;
      for (InteractionModel item in items) {
        rating = item.rating! as double;
      }
      rating = rating / items.length;
      return rating;
    } catch (e) {
      print(e);
      return 0;
    }

  }
}
