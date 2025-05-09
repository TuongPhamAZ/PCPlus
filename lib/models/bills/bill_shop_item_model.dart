import 'package:cloud_firestore/cloud_firestore.dart';

class BillShopItemModel {

  String? itemID;
  String? name;
  String? sellerID;
  String? itemType;
  String? description;
  String? detail;
  DateTime? addDate;
  int? price;
  String? image;
  String? color;
  int? amount;
  int? totalCost;

  BillShopItemModel(
      {
        required this.itemID,
        required this.name,
        required this.itemType,
        required this.sellerID,
        this.description,
        this.detail,
        required this.addDate,
        required this.price,
        this.image,
        required this.color,
        required this.amount,
        required this.totalCost,
      });

  Map<String, dynamic> toJson() => {
    'itemID': itemID,
    'name': name,
    'sellerID': sellerID,
    'itemType': itemType,
    'addDate': addDate,
    'description': description,
    'detail': detail,
    'price': price,
    'image': image,
    'color': color,
    'amount': amount,
    'totalCost': totalCost,
  };

  static BillShopItemModel fromJson(Map<String, dynamic> json) {

    return BillShopItemModel(
      itemID: json['itemID'] as String,
      name: json['name'] as String,
      sellerID: json['sellerID'] as String,
      itemType: json['itemType'] as String,
      addDate: (json['addDate'] as Timestamp).toDate(),
      description: json['description'] as String,
      detail: json['detail'] as String,
      price: json['price'] as int,
      image: json['image'] as String,
      color: json['color'] as String,
      amount: json['amount'] as int,
      totalCost: json['totalCost'] as int,
    );
  }

  bool isEqual(BillShopItemModel model) {
    return
      itemID == model.itemID
          && itemType == model.itemType
          && name == model.name
          && detail == model.detail
          && sellerID == model.sellerID
          && price == model.price
          && description == model.description
          && addDate?.compareTo(model.addDate!) == 0
          && image == model.image
          && color == model.color
          && amount == model.amount
          && totalCost == model.totalCost;
  }
}