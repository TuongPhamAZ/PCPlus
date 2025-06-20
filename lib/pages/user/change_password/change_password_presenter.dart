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
      _view.onChangedFailed("Mật khẩu phải từ 8 ký tự trở lên");
      return;
    } else if (newPass != rePass) {
      _view.onChangedFailed("Mật khẩu không khớp");
    }

    String password = await PrefService.getPassword();
    if (oldPass != password) {
      _view.onChangedFailed("Mật khẩu cũ sai");
      return;
    } else if (newPass == password) {
      _view.onChangedFailed("Mật khẩu mới phải khác mật khẩu cũ");
     return;
    }
    _view.onWaitingProgressBar();
    bool result = await _auth.changePassword(newPass);
    _view.onPopContext();
    if (result) {
      _view.onChangeSucceeded();
    } else {
      _view.onChangedFailed("Đã có lỗi xảy ra. Hãy thử lại sau.");
    }
  }
}