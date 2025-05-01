import 'package:flutter/cupertino.dart';
import 'package:pcplus/models/items/item_with_seller.dart';

import '../../interfaces/command.dart';
import '../../pages/widgets/listItem/shop_item.dart';

class ShopItemFactory {
  static Widget create({
    required ItemWithSeller data,
    required ICommand editCommand,
    required ICommand deleteCommand,
    required ICommand pressedCommand,
    required bool isShop
  }) {
    return ShopItem(
      itemName: data.item.name!,
      imagePath: data.item.image!,
      location: data.seller.location!,
      rating: data.item.rating!,
      price: data.item.price!,
      sold: data.item.sold!,
      editCommand: editCommand,
      deleteCommand: deleteCommand,
      pressedCommand: pressedCommand,
      description: data.item.description!,
      quantity: data.item.stock!,
      isShop: isShop,
    );
  }
}