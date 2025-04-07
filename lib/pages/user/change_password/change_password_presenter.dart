import 'package:pcplus/pages/user/change_password/change_password_contract.dart';
import 'package:pcplus/services/authentication_service.dart';
import 'package:pcplus/services/pref_service.dart';

class ChangePasswordPresenter {
  final ChangePasswordContract _view;
  ChangePasswordPresenter(this._view);

  final AuthenticationService _auth = AuthenticationService();

  Future<void> handleChange({
    required String oldPass,
    required String newPass,
    required String rePass}
  ) async {
    if (newPass.length < 8) {
      _view.onChangedFailed("Password must be equal or more than 8 characters");
      return;
    } else if (newPass != rePass) {
      _view.onChangedFailed("Passwords do not match");
    }

    String password = await PrefService.getPassword();
    if (oldPass != password) {
      _view.onChangedFailed("Incorrect old password");
      return;
    } else if (newPass == password) {
      _view.onChangedFailed("New password must be different from old one");
     return;
    }
    _view.onWaitingProgressBar();
    bool result = await _auth.changePassword(newPass);
    _view.onPopContext();
    if (result) {
      _view.onChangeSucceeded();
    } else {
      _view.onChangedFailed("Something was wrong. Please try again.");
    }
  }
}