import 'package:pcplus/builders/widget_builders/new_item_builder.dart';
import 'package:pcplus/builders/widget_builders/review_item_builder.dart';
import 'package:pcplus/builders/widget_builders/shop_item_builder.dart';
import 'package:pcplus/builders/widget_builders/suggest_item_builder.dart';
import 'package:pcplus/builders/widget_builders/widget_builder_interface.dart';
import 'package:pcplus/commands/command_interface.dart';
import 'package:pcplus/commands/shop_home_command.dart';

import '../../objects/review_data.dart';
import '../../objects/suggest_item_data.dart';

class WidgetBuilderDirector {
  void makeNewItem({
    required WidgetBuilderInterface builder, required ItemData data, required CommandInterface command
  }) {
    if (builder is NewItemBuilder) {
      NewItemBuilder itemBuilder = builder;
      itemBuilder.reset();
      itemBuilder.setProduct(data.product!);
      itemBuilder.setCommand(command);
      itemBuilder.setShop(data.shop!);
      itemBuilder.setRating(data.rating!);
    }
  }

  void makeSuggestItem({
    required WidgetBuilderInterface builder,
    required ItemData data,
    required CommandInterface command
  }) {
    if (builder is SuggestItemBuilder) {
      SuggestItemBuilder itemBuilder = builder;
      itemBuilder.reset();
      itemBuilder.setProduct(data.product!);
      itemBuilder.setShop(data.shop!);
      itemBuilder.setRating(data.rating!);
      itemBuilder.setCommand(command);
    }
  }

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
    required CommandInterface editCommand,
    required CommandInterface deleteCommand,
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