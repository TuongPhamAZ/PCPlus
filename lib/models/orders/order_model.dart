import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/orders/order_item_model.dart';
import 'package:pcplus/models/orders/order_address_model.dart';

class OrderModel {

  String? orderID;
  String? receiverID;
  String? receiverName;
  String? shopName;
  DateTime? orderDate;
  String? status;
  OrderAddressModel? address;
  OrderItemModel? itemModel;
  int? amount;
  String? deliveryMethod;
  int? deliveryCost;

  static String collectionName = 'Orders';

  OrderModel(
      {
        required this.orderID,
        required this.shopName,
        required this.receiverID,
        required this.receiverName,
        required this.orderDate,
        required this.status,
        required this.address,
        required this.itemModel,
        required this.deliveryMethod,
        required this.deliveryCost,
        required this.amount,
      });

  Map<String, dynamic> toJson() => {
    'orderID': orderID,
    'shopName': shopName,
    'receiverID': receiverID,
    'receiverName': receiverName,
    'orderDate': orderDate,
    'status': status,
    'address': address?.toJson(),
    'itemModel': itemModel?.toJson(),
    'deliveryMethod': deliveryMethod,
    'deliveryCost': deliveryCost,
    'amount': amount,
  };

  static OrderModel fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderID: json['orderID'] as String,
      shopName: json['shopName'] as String,
      receiverID: json['receiverID'] as String,
      receiverName: json['receiverName'] as String,
      orderDate: (json['orderDate'] as Timestamp).toDate(),
      status: json['status'] as String,
      address: OrderAddressModel.fromJson(json['address']),
      itemModel: OrderItemModel.fromJson(json['itemModel']),
      deliveryMethod: json['deliveryMethod'] as String,
      deliveryCost:  json['deliveryCost'] as int,
      amount: json['amount'] as int
    );
  }

}