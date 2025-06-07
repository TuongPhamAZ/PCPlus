abstract class BillProductContract {
  void onWaitingProgressBar();
  void onPopContext();
  void onBuy();
  void onWaitingForPayment();
  void onBuyFailed(String message);
  void onBack();
  void onChangeDelivery();
  void onChangeVoucher();
  void onShowResultDialog(String title, String message, bool isSuccess);
  void onLoadDataSucceeded();
  void onPaymentMethodChanged();
  void onShowPaymentWaitingDialog();
  void onShowChangePaymentMethodButton();
}
