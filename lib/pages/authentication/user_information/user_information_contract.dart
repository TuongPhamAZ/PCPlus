import '../../../models/users/user_model.dart';

abstract class UserInformationContract {
  void onConfirmSucceeded(UserModel userModel, String password);
  void onConfirmFailed(String message);
  void onWaitingProgressBar();
  void onPopContext();
}