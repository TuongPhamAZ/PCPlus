abstract class StatisticContract {
  void onLoadDataSucceeded();
  void onWaitingProgressBar();
  void onPopContext();
  void onChangeItemType(String itemType);
  void onChangeStatisticMode(String mode);
  void onChangeMonth(String month);
  void onChangeYear(String year);
}