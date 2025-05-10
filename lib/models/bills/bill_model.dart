import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pcplus/const/tax_rate.dart';
import 'package:pcplus/models/bills/bill_of_shop_model.dart';
import 'package:pcplus/models/bills/bill_shop_model.dart';
import 'package:pcplus/models/users/ship_infor_model.dart';

class BillModel {

  String? billID;
  String? userID;
  List<BillShopModel>? shops;
  DateTime? orderDate;
  String? status;
  ShipInformationModel? shipInformation;
  String? paymentType;
  int? totalPrice;

  static String collectionName = 'Bills';

  BillModel(
      {
        required this.billID,
        required this.userID,
        required this.shops,
        required this.orderDate,
        required this.status,
        required this.shipInformation,
        required this.paymentType,
        required this.totalPrice,
      });

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'shops': (shops ?? []).map((shop) => shop.toJson()).toList(),
    'orderDate': orderDate,
    'status': status,
    'shipInformation': shipInformation,
    'paymentType': paymentType,
    'totalPrice': totalPrice,
  };

  static BillModel fromJson(String id, Map<String, dynamic> json) {
    final dataShops = json['shops'] as List?;
    final listShops = List.castFrom<Object?, Map<String, Object?>>(dataShops!);

    return BillModel(
        billID: id,
        userID: json['userID'] as String,
        shops: listShops.map((raw) => BillShopModel.fromJson(raw)).toList(),
        orderDate: (json['orderDate'] as Timestamp).toDate(),
        status: json['status'] as String,
        shipInformation: ShipInformationModel.fromJson(json['shipInformation']),
        paymentType: json['paymentType'] as String,
        totalPrice:  json['totalPrice'] as int,
    );
  }

  BillOfShopModel? toBillOfShopModel(String shopID) {
    if (shops == null) {
      return null;
    }

    BillShopModel? billShopModel;

    for (BillShopModel shop in shops!) {
      if (shop.shopID == shopID) {
        billShopModel = shop;
        break;
      }
    }

    if (billShopModel == null) {
      return null;
    }

    int vat = (totalPrice! * TaxRate.vat).round();
    int pit = (totalPrice! * TaxRate.pit).round();
    int commissionFee = (totalPrice! * TaxRate.commissionFee).round();

    return BillOfShopModel(
        billID: billID,
        userID: userID,
        items: billShopModel.buyItems,
        orderDate: orderDate,
        status: status,
        shipInformation: shipInformation,
        paymentType: paymentType,
        totalPrice: totalPrice,
        vat: vat,
        pit: pit,
        commissionFee: commissionFee,
        payout: totalPrice! - vat - pit - commissionFee,
    );
  }

}