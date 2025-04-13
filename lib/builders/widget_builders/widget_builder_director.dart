import 'package:pcplus/builders/widget_builders/review_item_builder.dart';
import 'package:pcplus/builders/widget_builders/shop_item_builder.dart';
import 'package:pcplus/builders/widget_builders/widget_builder_interface.dart';
import 'package:pcplus/commands/shop_home_command.dart';

import '../../interfaces/command.dart';
import '../../objects/review_data.dart';
import '../../objects/suggest_item_data.dart';

class WidgetBuilderDirector {


  void makeReviewItem({
    required WidgetBuilderInterface builder,
    required ReviewData data,
  }) {
    if (builder is ReviewItemBuilder) {
      ReviewItemBuilder itemBuilder = builder;
      itemBuilder.reset();
      itemBuilder.setReviewData(data);
    }
  }

  void makeShopItem({
    required WidgetBuilderInterface builder,
    required ItemData data,
    required ICommand editCommand,
    required ICommand deleteCommand,
    required ShopHomeItemPressedCommand pressedCommand,
    required bool isShop
  }) {
    if (builder is ShopItemBuilder) {
      ShopItemBuilder itemBuilder = builder;
      itemBuilder.reset();
      itemBuilder.setProduct(data.product!);
      itemBuilder.setEditCommand(editCommand);
      itemBuilder.setDeleteCommand(deleteCommand);
      itemBuilder.setPressedCommand(pressedCommand);
      itemBuilder.setShop(data.shop!);
      itemBuilder.setRating(data.rating!);
      itemBuilder.setIsShop(isShop);
    }
  }
}