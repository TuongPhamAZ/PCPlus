import 'package:pcplus/models/items/item_with_seller.dart';

abstract class HomeContract {
  void onLoadDataSucceed();
  void onItemPressed(ItemWithSeller itemData);
  void onSearch();
  void onWaitingProgressBar();
  void onPopContext();
}