import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/objects/data_object_interface.dart';

import '../models/items/item_model.dart';

class InCartItemData extends IDataObject {
  ItemModel? item;
  UserModel? shop;
  double rating = 0;
  int colorIndex = 0;
  int amount = 0;
  String noteForShop = "";
  String deliveryMethod = "";
  int deliveryCost = 0;
  bool isCheck = false;

  InCartItemData({
    required this.item,
    required this.rating,
    required this.colorIndex,
    required this.amount,
    this.shop
  });

  bool isBuyable() {
    if (item == null) {
      return false;
    }
    return amount <= item!.stock!;
  }

  void clearPaymentInfo() {
    noteForShop = "";
    deliveryMethod = "";
    deliveryCost = 0;
  }
}