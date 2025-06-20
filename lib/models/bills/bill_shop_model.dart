import 'package:pcplus/models/bills/bill_shop_item_model.dart';

import '../vouchers/voucher_model.dart';

class BillShopModel {

  String? shopID;
  String? shopName;
  List<BillShopItemModel>? buyItems;
  String? status;
  VoucherModel? voucher;
  int? totalPrice;
  String? noteForShop = "";
  String? deliveryMethod = "";
  int? deliveryCost = 0;

  BillShopModel(
      {
        required this.shopID,
        required this.shopName,
        required this.buyItems,
        required this.status,
        required this.voucher,
        this.totalPrice,
        this.noteForShop,
        this.deliveryMethod,
        this.deliveryCost,
      });

  Map<String, dynamic> toJson() {
    totalPrice = 0;

    for (BillShopItemModel item in buyItems!) {
      totalPrice = totalPrice! + item.amount! * item.price!;
    }

    if (voucher != null) {
      totalPrice = totalPrice! - voucher!.discount!;
    }

    return {
      'shopID': shopID,
      'shopName': shopName,
      'buyItems': (buyItems ?? []).map((item) => item.toJson()).toList(),
      'status': status,
      'voucher': voucher?.toJson(),
      'totalPrice': totalPrice,
      'noteForShop': noteForShop ?? "",
      'deliveryMethod': deliveryMethod ?? "",
      'deliveryCost': deliveryCost ?? 0,
    };
  }

  static BillShopModel fromJson(Map<String, dynamic> json) {
    final dataItems = json['buyItems'] as List?;
    final listItems = List.castFrom<Object?, Map<String, dynamic>>(dataItems!);

    return BillShopModel(
      shopID: json['shopID'] as String,
      shopName: json['shopName'] as String,
      buyItems: listItems.map((raw) => BillShopItemModel.fromJson(raw)).toList(),
      status: json['status'] as String,
      voucher: VoucherModel.fromJson("", json['voucher']),
      totalPrice: json['totalPrice'] as int,
      noteForShop: (json['noteForShop'] ?? "") as String,
      deliveryMethod: (json['deliveryMethod'] ?? "") as String,
      deliveryCost:  (json['deliveryCost'] ?? 0) as int,
    );
  }
}