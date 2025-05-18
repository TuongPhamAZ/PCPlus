import 'package:pcplus/models/items/item_with_seller.dart';

abstract class SearchScreenContract {
  void onStartSearching();
  void onFinishSearching();
  void onChangeFilter();
  void onBack();
  void onSelectItem(ItemWithSeller item);
  void onPopContext();
  void onWaitingProgressBar();
}