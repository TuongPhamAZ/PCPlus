abstract class DetailProductContract {
  void onLoadDataSucceeded();
  void onAddToCart();
  void onBuyNow();
  void onBack();
  void onWaitingProgressBar();
  void onPopContext();
  void onViewShop(String sellerID);
  void onError(String message);
}