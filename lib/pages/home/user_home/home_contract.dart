import 'package:pcplus/models/items/item_with_seller.dart';

abstract class HomeContract {
  void onLoadDataSucceed();
  void onItemPressed(ItemWithSeller itemData);
  void onSearch(String text);
  void onWaitingProgressBar();
  void onPopContext();
}