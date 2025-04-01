import 'package:flutter/src/widgets/framework.dart';
import 'package:pcplus/builders/widget_builders/widget_builder_interface.dart';
import 'package:pcplus/commands/command_interface.dart';
import 'package:pcplus/models/items/item_model.dart';

import '../../models/users/user_model.dart';
import '../../pages/widgets/listItem/new_item.dart';

class NewItemBuilder implements WidgetBuilderInterface {
  ItemModel? _product;
  UserModel? _shop;
  CommandInterface? _command;
  double? _rating = 4.5;

  void setProduct(ItemModel product) {
    _product = product;
  }

  void setCommand(CommandInterface command) {
    _command = command;
  }

  void setShop(UserModel shop) {
    _shop = shop;
  }

  void setRating(double rating) {
    _rating = rating;
  }

  @override
  Widget? createWidget() {
    if (_product == null || _shop == null) {
      return null;
    }
    return NewItem(
        itemName: _product!.name!,
        imagePath: _product!.image!,
        command: _command,
        location: _shop!.getLocation(),
        rating: _rating!,
        price: _product!.price!,
        sold: _product!.sold!
    );
  }

  @override
  void reset() {
    _product = null;
    _shop = null;
    _rating = 4.5;
    _command = null;
  }

}