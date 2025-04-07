import 'package:pcplus/pages/home/user_home/home_presenter.dart';

import '../interfaces/command.dart';
import '../models/items/item_with_seller.dart';

class HomeItemPressedCommand implements ICommand {
  final HomePresenter presenter;
  final ItemWithSeller item;

  HomeItemPressedCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemPressed(item);
  }
}