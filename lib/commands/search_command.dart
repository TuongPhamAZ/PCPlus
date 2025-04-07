import 'package:pcplus/interfaces/command.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/search/search_screen_presenter.dart';

class SearchItemPressedCommand implements ICommand {
  final SearchScreenPresenter presenter;
  final ItemWithSeller item;

  SearchItemPressedCommand({
    required this.presenter,
    required this.item
  });

  @override
  void execute() {
    presenter.handleItemPressed(item);
  }
}