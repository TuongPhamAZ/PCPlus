import 'package:pcplus/models/bills/bill_shop_item_model.dart';

import '../vouchers/voucher_model.dart';

class BillShopModel {

  String? shopID;
  String? shopName;
  List<BillShopItemModel>? buyItems;
  String? status;
  VoucherModel? voucher;
  int? totalPrice;

  BillShopModel(
      {
        required this.shopID,
        required this.shopName,
        required this.buyItems,
        required this.status,
        required this.voucher,
        this.totalPrice,
      });

  Map<String, dynamic> toJson() {
    totalPrice = 0;

    for (BillShopItemModel item in buyItems!) {
      totalPrice = totalPrice! + item.amount! * item.price!;
    }

    totalPrice = (totalPrice! * (100 - voucher!.discount!) / 100).round();

    return {
      'shopID': shopID,
      'shopName': shopName,
      'buyItems': (buyItems ?? []).map((item) => item.toJson()).toList(),
      'status': status,
      'voucher': voucher,
      'totalPrice': totalPrice,
    };
  }

  static BillShopModel fromJson(Map<String, dynamic> json) {
    final dataItems = json['buyItems'] as List?;
    final listItems = List.castFrom<Object?, Map<String, Object?>>(dataItems!);

    return BillShopModel(
      shopID: json['shopID'] as String,
      shopName: json['shopName'] as String,
      buyItems: listItems.map((raw) => BillShopItemModel.fromJson(raw)).toList(),
      status: json['status'] as String,
      voucher: VoucherModel.fromJson("", json['voucher']),
      totalPrice: json['totalPrice'] as int,
    );
  }
}