import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/models/users/voucher_of_user_model.dart';
import '../items/item_model.dart';

class VoucherOfUserRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;

  Future<String?> addVoucherOfUserToFirestore(String userID, VoucherOfUserModel model) async {
    try {
      DocumentReference docRef =
      _storage.collection(UserModel.collectionName)
          .doc(userID)
          .collection(VoucherOfUserModel.collectionName)
          .doc();
      await docRef.set(model.toJson()).whenComplete(()
      => print('Rating added to Firestore with ID: ${docRef.id}'));
      model.voucherID = docRef.id;
      return docRef.id;
    } catch (e) {
      print('Error adding Rating to Firestore: $e');
      return null;
    }
  }

  Future<void> deleteVoucherOfUserById(String itemId, String voucherID) async
  => _storage.collection(ItemModel.collectionName)
          .doc(itemId)
          .collection(VoucherOfUserModel.collectionName)
          .doc(voucherID)
          .delete();

  Future<bool> updateVoucherOfUser(String userID, VoucherOfUserModel model) async {
    bool isSuccess = false;

    await _storage.collection(ItemModel.collectionName)
        .doc(userID)
        .collection(VoucherOfUserModel.collectionName)
        .doc(model.voucherID)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<VoucherOfUserModel> getVoucherOfUser(String userID, String voucherID) async {
    final DocumentReference<Map<String, dynamic>> collectionRef
    = _storage.collection(ItemModel.collectionName)
        .doc(userID)
        .collection(VoucherOfUserModel.collectionName)
        .doc(voucherID);
    DocumentSnapshot<Map<String, dynamic>> doc = await collectionRef.get();

    final VoucherOfUserModel model = VoucherOfUserModel.fromJson(doc.id, doc.data() as Map<String, dynamic>);
    return model;
  }

  Stream<List<VoucherOfUserModel>> getAllVouchersOfUserStream(String userID) {
    return _storage
        .collection(UserModel.collectionName)
        .doc(userID)
        .collection(VoucherOfUserModel.collectionName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VoucherOfUserModel.fromJson(doc.id, doc.data()))
          .toList();
    });
  }
}
