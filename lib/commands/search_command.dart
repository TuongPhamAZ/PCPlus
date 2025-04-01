import 'package:pcplus/pages/search/search_screen_presenter.dart';

import '../objects/suggest_item_data.dart';
import 'command_interface.dart';

class SearchItemPressedCommand implements CommandInterface {
  final SearchScreenPresenter presenter;
  final ItemData item;

  SearchItemPressedCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemPressed(item);
  }
}