import 'package:cloud_firestore/cloud_firestore.dart';

import '../bills/bill_shop_item_model.dart';
import '../users/ship_infor_model.dart';
import '../vouchers/voucher_model.dart';

class AwaitRatingModel {

  String? key;
  BillShopItemModel? item;
  String? shopName;
  DateTime? createdAt;

  static String collectionName = 'AwaitRatings';

  AwaitRatingModel(
      {
        this.key,
        required this.item,
        required this.shopName,
        required this.createdAt,
      });

  Map<String, dynamic> toJson() => {
    'item': item!.toJson(),
    'shopName': shopName,
    'createdAt': createdAt,
  };

  static AwaitRatingModel fromJson(String id, Map<String, dynamic> json) {

    return AwaitRatingModel(
      key: id,
      item: BillShopItemModel.fromJson(json['item']),
      shopName: json['shopName'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

}