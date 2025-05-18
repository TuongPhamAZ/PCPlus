abstract class BillProductContract {
  void onWaitingProgressBar();
  void onPopContext();
  void onBuy();
  void onBuyFailed(String message);
  void onBack();
  void onChangeDelivery();

  void onLoadDataSucceeded();
}