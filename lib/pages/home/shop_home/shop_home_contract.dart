
import 'package:pcplus/models/items/item_with_seller.dart';

abstract class ShopHomeContract {
  void onLoadDataSucceeded();
  // void onFetchDataSucceeded();
  void onWaitingProgressBar();
  void onPopContext();
  void onItemEdit(ItemWithSeller item);
  void onItemDelete();
  void onItemPressed(ItemWithSeller item);
  void onBack();
}