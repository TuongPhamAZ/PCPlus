abstract class HistoryOrderContract {
  void onLoadDataSucceeded();
  void onItemPressed();
  void onWaitingProgressBar();
  void onPopContext();
  void onError(String message);
}