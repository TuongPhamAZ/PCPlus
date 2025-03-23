import 'package:pcplus/commands/command_interface.dart';
import 'package:pcplus/presenter/home_presenter.dart';

import '../objects/suggest_item_data.dart';

class HomeItemPressedCommand implements CommandInterface {
  final HomePresenter presenter;
  final ItemData item;

  HomeItemPressedCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemPressed(item);
  }
}