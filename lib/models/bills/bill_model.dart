import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/const/tax_rate.dart';
import 'package:pcplus/models/bills/bill_of_shop_model.dart';
import 'package:pcplus/models/bills/bill_shop_model.dart';
import 'package:pcplus/models/users/ship_infor_model.dart';

class BillModel {

  String? billID;
  String? userID;
  List<BillShopModel>? shops;
  DateTime? orderDate;
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
        required this.shipInformation,
        required this.paymentType,
        required this.totalPrice,
      });

  Map<String, dynamic> toJson() {
    totalPrice = 0;

    for (BillShopModel billShop in shops!) {
      billShop.toJson();
      totalPrice = totalPrice! + billShop.totalPrice! + billShop.deliveryCost!;
    }

    return {
      'userID': userID,
      'shops': (shops ?? []).map((shop) => shop.toJson()).toList(),
      'orderDate': orderDate,
      'shipInformation': shipInformation?.toJson(),
      'paymentType': paymentType,
      'totalPrice': totalPrice,
    };
  }

  static BillModel fromJson(String id, Map<String, dynamic> json) {
    final dataShops = json['shops'] as List?;
    final listShops = List.castFrom<Object?, Map<String, dynamic>>(dataShops!);

    return BillModel(
        billID: id,
        userID: json['userID'] as String,
        shops: listShops.map((raw) => BillShopModel.fromJson(raw)).toList(),
        orderDate: (json['orderDate'] as Timestamp).toDate(),
        shipInformation: ShipInformationModel.fromJson(json['shipInformation']),
        paymentType: json['paymentType'] as String,
        totalPrice:  json['totalPrice'] as int,
    );
  }

  BillShopModel? getBillShopModel(String shopID) {
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

    return billShopModel;
  }

  bool updateShopStatus(String shopID, String status) {
    if (shops == null) {
      return false;
    }

    BillShopModel? billShopModel;

    for (BillShopModel shop in shops!) {
      if (shop.shopID == shopID) {
        billShopModel = shop;
        break;
      }
    }

    if (billShopModel == null) {
      return false;
    }

    billShopModel.status = status;
    return true;
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

    int vat = (billShopModel.totalPrice! * TaxRate.vat).round();
    int pit = (billShopModel.totalPrice! * TaxRate.pit).round();
    int commissionFee = (billShopModel.totalPrice! * TaxRate.commissionFee).round();

    return BillOfShopModel(
        billID: billID,
        userID: userID,
        items: billShopModel.buyItems,
        orderDate: orderDate,
        status: billShopModel.status,
        shipInformation: shipInformation,
        voucher: billShopModel.voucher,
        paymentType: paymentType,
        totalPrice: billShopModel.totalPrice,
        vat: vat,
        pit: pit,
        commissionFee: commissionFee,
        payout: billShopModel.totalPrice! - vat - pit - commissionFee,
    );
  }

}

class PaymentType {
  static const String byCashOnDelivery = "Cash";
  static const String byMomo = "Momo";
}