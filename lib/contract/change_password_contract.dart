abstract class ChangePasswordContract {
  void onWaitingProgressBar();
  void onPopContext();
  void onChangeSucceeded();
  void onChangedFailed(String message);
}