abstract class AddProductContract {
  void onWaitingProgressBar();
  void onPopContext();
  void onAddFailed(String message);
  void onAddSuccessWithVector(); // Thành công và có vector
  void onAddSuccessWithoutVector(); // Thành công nhưng không có vector
}
