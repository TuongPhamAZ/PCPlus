import 'package:cloud_firestore/cloud_firestore.dart';

import '../users/ship_infor_model.dart';
import 'bill_shop_item_model.dart';

class BillOfShopModel {

  String? billID;
  String? userID;
  List<BillShopItemModel>? items;
  DateTime? orderDate;
  String? status;
  ShipInformationModel? shipInformation;
  String? paymentType;
  int? totalPrice;
  // VoucherModel? voucher;

  static String collectionName = 'Bills';

  BillOfShopModel(
      {
        required this.billID,
        required this.userID,
        required this.items,
        required this.orderDate,
        required this.status,
        required this.shipInformation,
        required this.paymentType,
        required this.totalPrice,

      });

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'items': (items ?? []).map((item) => item.toJson()).toList(),
    'orderDate': orderDate,
    'status': status,
    'shipInformation': shipInformation,
    'paymentType': paymentType,
    'totalPrice': totalPrice,
  };

  static BillOfShopModel fromJson(String id, Map<String, dynamic> json) {
    final dataItems = json['items'] as List?;
    final listItems = List.castFrom<Object?, Map<String, Object?>>(dataItems!);

    return BillOfShopModel(
      billID: id,
      userID: json['userID'] as String,
      items: listItems.map((raw) => BillShopItemModel.fromJson(raw)).toList(),
      orderDate: (json['orderDate'] as Timestamp).toDate(),
      status: json['status'] as String,
      shipInformation: ShipInformationModel.fromJson(json['shipInformation']),
      paymentType: json['paymentType'] as String,
      totalPrice:  json['totalPrice'] as int,
    );
  }

}