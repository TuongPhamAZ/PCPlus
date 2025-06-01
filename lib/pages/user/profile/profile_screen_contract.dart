abstract class ProfileScreenContract {
  void onLoadDataSucceeded();
  void onSignOut();
  void onWaitingProgressBar();
  void onPopContext();
  void onUpdateOrdersCount();
  void onUnsubtopicSucceeded();
  void onUnsubtopicFailed(String error);
}
