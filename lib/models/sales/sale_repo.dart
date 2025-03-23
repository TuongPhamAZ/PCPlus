import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/sales/sale_model.dart';

class SaleRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  void addSaleToFirestore(SaleModel model) async {
    try {
      DocumentReference docRef = _storage.collection(SaleModel.collectionName).doc(model.saleID);
      await docRef.set(model.toJson()).whenComplete(()
      => print('Sale added to Firestore with ID: ${docRef.id}'));
    } catch (e) {
      print('Error adding Sale to Firestore: $e');
    }
  }

  void deleteSaleById(String id) async => _storage.collection(SaleModel.collectionName).doc(id).delete();

  Future<bool> updateItem(SaleModel model) async {
    bool isSuccess = false;

    await _storage.collection(SaleModel.collectionName)
        .doc(model.saleID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<SaleModel> getSaleById(String id) async {
    final DocumentReference<Map<String, dynamic>> collectionRef = _storage.collection(SaleModel.collectionName).doc(id);
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await collectionRef.get();

    final SaleModel item = SaleModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
    return item;
  }
}
