abstract class RegisterViewContract {
  void onWaitingProgressBar() {}
  void onPopContext() {}
  void onEmailAlreadyInUse() {}
  void onRegisterSucceeded(String email) {}
  void onRegisterFailed() {}
}