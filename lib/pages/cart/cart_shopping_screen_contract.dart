abstract class CartShoppingScreenContract {
  void onLoadDataSucceeded();
  void onWaitingProgressBar();
  void onPopContext();
  void onBuy();
  void onSelectItem();
  void onDeleteItem();
  void onItemPressed();
  void onBuyFailed(String message);
  void onChangeItemAmount();
}