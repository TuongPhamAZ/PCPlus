import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/system/param_store_model.dart';

class ParamStoreRepository {
  final FirebaseFirestore _storage = FirebaseFirestore.instance;
// final FirebaseAuth _auth = FirebaseAuth.instance
  final collectionName = "params";
  final id = "main";

  Future<bool> updateParamStore(ParamStoreModel model) async {
    bool isSuccess = false;

    await _storage.collection(collectionName)
        .doc(id)
        .update(model.toJson())
        .then((_) => isSuccess = true);

    return isSuccess;
  }

  Future<ParamStoreModel> getParamStore() async {
    final DocumentReference<Map<String, dynamic>> collectionRef
      = _storage.collection(collectionName).doc(id);
    DocumentSnapshot<Map<String, dynamic>> doc = await collectionRef.get();

    final ParamStoreModel model = ParamStoreModel.fromJson(doc.data() as Map<String, dynamic>);
    return model;
  }

  Future<void> increaseOrderIdIndex() async {
    ParamStoreModel paramStore = await getParamStore();
    paramStore.orderIdIndex ++;
    updateParamStore(paramStore);
  }

  Future<int> getOrderIdIndex() async {
    ParamStoreModel paramStore = await getParamStore();
    return paramStore.orderIdIndex;
  }
}