import '../../models/items/item_with_seller.dart';

abstract class ImageSearchResultContract {
  void onLoadDataSucceed();
  void onLoadDataFailed(String message);
  void onItemPressed(ItemWithSeller itemData);
  void onBack();
}
