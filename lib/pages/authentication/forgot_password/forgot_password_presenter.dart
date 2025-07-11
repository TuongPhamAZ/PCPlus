import 'package:pcplus/pages/authentication/forgot_password/forgot_password_contract.dart';
import 'package:pcplus/services/authentication_service.dart';

class ForgotPasswordPresenter {
  final ForgotPasswordContract _view;
  ForgotPasswordPresenter(this._view);
  final AuthenticationService _auth = AuthenticationService();

  Future<void> resetPassword(String email) async {
    _view.onWaitingProgressBar();
    AuthResult authResult = AuthResult();
    bool? result = await _auth.checkIfEmailExists(email, authResult);

    if (result == null || result == false){
      _view.onPopContext();
      _view.onForgotPasswordError("Email này chưa được đăng ký.");
      return;
    }

    String? error = await _auth.sendPasswordResetEmail(email);

    if (error == null){
      _view.onPopContext();
      _view.onForgotPasswordSent();
    } else {
      _view.onPopContext();
      _view.onForgotPasswordError(error);
    }
  }
}