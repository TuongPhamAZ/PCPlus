import 'package:pcplus/models/items/item_with_seller.dart';

abstract class CartShoppingScreenContract {
  void onLoadDataSucceeded();
  void onWaitingProgressBar();
  void onPopContext();
  void onBuy();
  void onSelectItem();
  void onSelectAll();
  void onDeleteItem();
  void onItemPressed(ItemWithSeller data);
  void onBuyFailed(String message);
  void onChangeItemAmount();
}