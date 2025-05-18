import '../../../models/shops/shop_model.dart';

abstract class DetailProductContract {
  void onLoadDataSucceeded();
  void onAddToCart();
  void onBuyNow();
  void onBack();
  void onWaitingProgressBar();
  void onPopContext();
  void onViewShop(ShopModel seller);
  void onError(String message);
}