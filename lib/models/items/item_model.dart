import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/orders/order_item_model.dart';

import '../../services/utility.dart';
import '../bills/bill_shop_item_model.dart';
import 'color_model.dart';

class ItemModel {

  String? itemID;
  String? name;
  String? sellerID;
  String? itemType;
  String? description;
  String? detail;
  DateTime? addDate;
  int? price;
  int? stock;
  int? sold = 0;
  double? rating;
  String? status;
  List<String>? reviewImages = [];
  List<ColorModel>? colors = [];

  static String collectionName = 'Items';

  ItemModel(
    {
      this.itemID,
      required this.name,
      required this.itemType,
      required this.sellerID,
      this.description,
      this.detail,
      required this.addDate,
      required this.price,
      required this.stock,
      required this.status,
      required this.rating,
      this.reviewImages,
      required this.colors,
      this.sold
    }
  );

  String? get image => reviewImages?.first;

  Map<String, dynamic> toJson() => {
    'name': name,
    'sellerID': sellerID,
    'itemType': itemType,
    'addDate': addDate,
    'description': description,
    'detail': detail,
    'price': price,
    'stock': stock,
    'sold': sold,
    'status': status,
    'reviewImages': reviewImages,
    'colors': (colors ?? []).map((color) => color.toJson()).toList(),
    'rating': rating
  };

  static ItemModel fromJson(String key, Map<String, dynamic> json) {
    final reviewImagesData = json['reviewImages'] as List?;
    final dataColors = json['colors'] as List?;
    final listColors = List.castFrom<Object?, Map<String, Object?>>(dataColors!);

    return ItemModel(
      itemID: key,
      name: json['name'] as String,
      sellerID: json['sellerID'] as String,
      itemType: json['itemType'] as String,
      addDate: ((json['addDate'] ?? Timestamp.now()) as Timestamp).toDate(),
      description: json['description'] as String,
      detail: (json['detail'] ?? "") as String,
      price: json['price'] as int,
      stock: json['stock'] as int,
      sold: (json['sold'] ?? 0) as int,
      status: json['status'] as String,
      reviewImages: List.castFrom(reviewImagesData!),
      colors: listColors.map((raw) => ColorModel.fromJson(raw)).toList(),
      rating: (json['rating'] ?? 0.0) as double
    );
  }

  void addReviewImage(String url) {
    reviewImages?.add(url);
  }

  void addReviewImages(List<String> urls) {
    reviewImages?.addAll(urls);
  }

  void removeReviewImage(String url) {
    reviewImages?.remove(url);
  }

  void addColor(String color) {
    reviewImages?.add(color);
  }

  void addColors(List<String> colors) {
    reviewImages?.addAll(colors);
  }

  void removeColor(String color) {
    reviewImages?.remove(color);
  }

  bool isEqual(ItemModel model) {
    return
        itemID == model.itemID
        && itemType == model.itemType
        && name == model.name
        && detail == model.detail
        && sellerID == model.sellerID
        && stock == model.stock
        && price == model.price
        && sold == model.sold
        && description == model.description
        && addDate?.compareTo(model.addDate!) == 0
        && status == model.status
        && Utility.listStringIsEqual(reviewImages, model.reviewImages);
        // && Utility.listStringIsEqual(colors, model.colors);
  }

  OrderItemModel toOrderItemModel({
    required ColorModel color
  }) {
    return OrderItemModel(
      itemID: itemID,
      name: name,
      itemType: itemType,
      sellerID: sellerID,
      addDate: addDate,
      price: price,
      color: color,
      description: description,
      image: image,
      detail: detail
    );
  }

  BillShopItemModel toBillShopItemModel({
    required int colorIndex,
    required int amount,
  }) {
    return BillShopItemModel(
        itemID: itemID,
        name: name,
        itemType: itemType,
        sellerID: sellerID,
        addDate: addDate,
        price: price,
        color: colors![colorIndex].name,
        description: description,
        image: image,
        detail: detail,
        amount: amount,
        totalCost: price! * amount,
    );
  }
}

