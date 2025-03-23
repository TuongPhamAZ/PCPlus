import '../objects/suggest_item_data.dart';
import '../presenter/shop_home_presenter.dart';
import 'command_interface.dart';

class ShopHomeItemEditCommand implements CommandInterface {
  final ShopHomePresenter presenter;
  final ItemData item;

  ShopHomeItemEditCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemEdit(item);
  }
}

class ShopHomeItemDeleteCommand implements CommandInterface {
  final ShopHomePresenter presenter;
  final ItemData item;

  ShopHomeItemDeleteCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemDelete(item);
  }
}

class ShopHomeItemPressedCommand implements CommandInterface {
  final ShopHomePresenter presenter;
  final ItemData item;

  ShopHomeItemPressedCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemPressed(item);
  }
}

