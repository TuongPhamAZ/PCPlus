import 'package:pcplus/models/bills/bill_shop_item_model.dart';

class BillShopModel {

  String? shopID;
  List<BillShopItemModel>? buyItems;
  // VoucherModel? voucher;

  BillShopModel(
      {
        required this.shopID,
        required this.buyItems,
        // required this.voucherModel,
      });

  Map<String, dynamic> toJson() => {
    'shopID': shopID,
    'buyItems': (buyItems ?? []).map((item) => item.toJson()).toList(),
    // 'voucher': voucher,
  };

  static BillShopModel fromJson(Map<String, dynamic> json) {
    final dataItems = json['buyItems'] as List?;
    final listItems = List.castFrom<Object?, Map<String, Object?>>(dataItems!);

    return BillShopModel(
      shopID: json['shopID'] as String,
      buyItems: listItems.map((raw) => BillShopItemModel.fromJson(raw)).toList(),
    );
  }
}