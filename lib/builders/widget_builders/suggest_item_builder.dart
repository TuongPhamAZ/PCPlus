import 'package:flutter/src/widgets/framework.dart';
import 'package:pcplus/builders/widget_builders/widget_builder_interface.dart';
import 'package:pcplus/commands/command_interface.dart';
import 'package:pcplus/models/items/item_model.dart';

import '../../models/users/user_model.dart';
import '../../views/widgets/listItem/suggest_item.dart';

class SuggestItemBuilder implements WidgetBuilderInterface {
  ItemModel? _product;
  UserModel? _shop;
  double? _rating = 4.5;
  CommandInterface? _command;

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
    return SuggestItem(
        itemName: _product!.name!,
        description: _product!.description!,
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
  }

}