import 'package:firebase_auth/firebase_auth.dart';
import 'package:pcplus/services/authentication_service.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/singleton/shop_singleton.dart';
import 'login_contract.dart';
import '../../../models/users/user_model.dart';
import '../../../models/users/user_repo.dart';
import '../../../singleton/user_singleton.dart';

class LoginPresenter {
  final LoginViewContract _view;
  LoginPresenter(this._view);
  final AuthenticationService _authService = AuthenticationService();
  final UserRepository _userRepo = UserRepository();
  final PrefService _prefService = PrefService();
  final UserSingleton _userSingleton = UserSingleton.getInstance();
  final ShopSingleton _shopSingleton = ShopSingleton.getInstance();

  Future<void> login(String email, String password) async {
    try {
      _view.onWaitingProgressBar();
      UserCredential? userCredential = await _authService.signInWithEmailAndPassword(email, password);
      if (userCredential == null) {
        _view.onPopContext();
        _view.onLoginFailed();
        return;
      }
      UserModel userData = await _userRepo.getUserById(userCredential.user!.uid);
      await _userSingleton.loadUser(userData);
      await _prefService.saveUserData(userData: userData, password: password);
    } catch (e) {
      print(e);
      _view.onPopContext();
      _view.onError();
      return;
    }
    _view.onPopContext();
    _view.onLoginSucceeded();
  }
}