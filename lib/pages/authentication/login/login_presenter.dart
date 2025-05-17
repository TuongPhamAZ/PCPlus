import 'package:firebase_auth/firebase_auth.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/services/authentication_service.dart';
import 'package:pcplus/services/pref_service.dart';
import 'login_contract.dart';
import '../../../models/users/user_model.dart';
import '../../../models/users/user_repo.dart';

class LoginPresenter {
  final LoginViewContract _view;
  LoginPresenter(this._view);
  final AuthenticationService _authService = AuthenticationService();
  final UserRepository _userRepo = UserRepository();
  final SessionController _sessionController = SessionController.getInstance();

  Future<void> login(String email, String password) async {
    try {
      _view.onWaitingProgressBar();
      AuthResult authResult = AuthResult();
      UserCredential? userCredential = await _authService.signInWithEmailAndPassword(email, password, authResult);

      if (authResult.code == AuthResult.WrongPassword
          || authResult.code == AuthResult.UserNotFound
          || authResult.code == AuthResult.InvalidCredential) {
        _view.onPopContext();
        _view.onLoginFailed();
        return;
      } else if (authResult.code == AuthResult.NetworkRequestFailed) {
        _view.onPopContext();
        _view.onError(authResult.text);
        return;
      } else if (authResult.code == AuthResult.UnknownError) {
        _view.onPopContext();
        _view.onError("Login failed.");
      }
      UserModel? userData = await _userRepo.getUserById(userCredential!.user!.uid);

      if (userData == null) {
        _view.onPopContext();
        _view.onError("Something was wrong. Please try again.");
        return;
      }

      await _sessionController.loadUser(userData);
      await PrefService.saveUserData(userData: userData, password: password);
    } catch (e) {
      print(e);
      _view.onPopContext();
      _view.onError("Something was wrong. Please try again.");
      return;
    }
    _view.onPopContext();
    _view.onLoginSucceeded();
  }
}