abstract class EditProductContract {
  void onWaitingProgressBar();
  void onPopContext();
  void onEditFailed(String message);
  void onEditSucceeded();
}