import 'package:cloud_firestore/cloud_firestore.dart';

import '../users/ship_infor_model.dart';
import '../vouchers/voucher_model.dart';
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
  int? vat;
  int? pit;
  int? commissionFee;
  int? payout;
  VoucherModel? voucher;

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
        required this.vat,
        required this.pit,
        this.voucher,
        required this.commissionFee,
        required this.payout,
      });

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'items': (items ?? []).map((item) => item.toJson()).toList(),
    'orderDate': orderDate,
    'status': status,
    'shipInformation': shipInformation?.toJson(),
    'paymentType': paymentType,
    'voucher': voucher,
    'totalPrice': totalPrice,
    'vat': vat,
    'pit': pit,
    'commissionFee': commissionFee,
    'payout': payout,
  };

  static BillOfShopModel fromJson(String id, Map<String, dynamic> json) {
    final dataItems = json['items'] as List?;
    final listItems = List.castFrom<Object?, Map<String, dynamic>>(dataItems!);

    return BillOfShopModel(
      billID: id,
      userID: json['userID'] as String,
      items: listItems.map((raw) => BillShopItemModel.fromJson(raw)).toList(),
      orderDate: (json['orderDate'] as Timestamp).toDate(),
      status: json['status'] as String,
      shipInformation: ShipInformationModel.fromJson(json['shipInformation']),
      voucher: VoucherModel.fromJson("", json['voucher']),
      paymentType: json['paymentType'] as String,
      totalPrice:  json['totalPrice'] as int,
      vat: json['vat'] as int,
      pit: json['pit'] as int,
      commissionFee: json['commissionFee'] as int,
      payout: json['payout'] as int,
    );
  }

}