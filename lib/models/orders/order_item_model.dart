import 'package:cloud_firestore/cloud_firestore.dart';
import '../items/color_model.dart';

class OrderItemModel {

  String? itemID;
  String? name;
  String? sellerID;
  String? itemType;
  String? description;
  String? detail;
  DateTime? addDate;
  int? price;
  String? image;
  ColorModel? color;

  OrderItemModel(
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
    'color': color
  };

  static OrderItemModel fromJson(Map<String, dynamic> json) {

    return OrderItemModel(
      itemID: json['itemID'] as String,
      name: json['name'] as String,
      sellerID: json['sellerID'] as String,
      itemType: json['itemType'] as String,
      addDate: (json['addDate'] as Timestamp).toDate(),
      description: json['description'] as String,
      detail: json['detail'] as String,
      price: json['price'] as int,
      image: json['image'] as String,
      color: ColorModel.fromJson(json['color']),
    );
  }

  bool isEqual(OrderItemModel model) {
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
          && color == model.color;
  }
}

