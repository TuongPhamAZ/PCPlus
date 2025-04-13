abstract class CartShoppingScreenContract {
  void onLoadDataSucceeded();
  void onWaitingProgressBar();
  void onPopContext();
  void onBuy();
  void onSelectItem();
  void onSelectAll();
  void onDeleteItem();
  void onItemPressed(String itemID);
  void onBuyFailed(String message);
  void onChangeItemAmount();
}