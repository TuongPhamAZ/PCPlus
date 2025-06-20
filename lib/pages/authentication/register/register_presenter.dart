import 'package:pcplus/services/authentication_service.dart';
import 'package:string_validator/string_validator.dart';

import 'register_contract.dart';

class RegisterPresenter {
  final RegisterViewContract? _view;
  final AuthenticationService _authService = AuthenticationService();
  RegisterPresenter(this._view);

  String? validateEmail(String? email) {
    email = email?.trim();
    if (email == null || email.isEmpty) {
      return "Vui lòng nhập email!";
    } else if (!isEmail(email)) {
      return "Cú pháp Email không hợp lệ!";
    }
    return null;
  }

  Future<void> register(String email) async {
    email = email.trim();
    _view?.onWaitingProgressBar();
    AuthResult authResult = AuthResult();
    bool? result = await _authService.checkIfEmailExists(email, authResult);
    _view?.onPopContext();

    if (result == true) {
      _view?.onEmailAlreadyInUse();
    } else if (result == false) {
      _view?.onRegisterSucceeded(email);
    } else if (result == null) {
      _view?.onRegisterFailed();
    }
  }
}