import 'package:pcplus/models/items/item_with_seller.dart';

import '../interfaces/command.dart';
import '../objects/suggest_item_data.dart';
import '../pages/home/shop_home/shop_home_presenter.dart';

class ShopHomeItemEditCommand implements ICommand {
  final ShopHomePresenter presenter;
  final ItemWithSeller item;

  ShopHomeItemEditCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemEdit(item);
  }
}

class ShopHomeItemDeleteCommand implements ICommand {
  final ShopHomePresenter presenter;
  final ItemWithSeller item;

  ShopHomeItemDeleteCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemDelete(item);
  }
}

class ShopHomeItemPressedCommand implements ICommand {
  final ShopHomePresenter presenter;
  final ItemWithSeller item;

  ShopHomeItemPressedCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemPressed(item);
  }
}

