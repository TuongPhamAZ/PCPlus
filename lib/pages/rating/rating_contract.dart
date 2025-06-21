abstract class RatingScreenContract {
  void onWaitingProgressBar() {}

  void onPopContext() {}

  void onLoadDataSucceeded() {}

  bool submitComment(String? comment);
}