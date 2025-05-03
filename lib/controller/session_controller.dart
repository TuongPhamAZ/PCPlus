
import 'package:pcplus/services/pref_service.dart';

import '../models/users/user_model.dart';

class SessionController {
  static SessionController? _instance;
  static SessionController getInstance() {
    _instance ??= SessionController();
    return _instance!;
  }

  String? userID;
  bool isSeller = false;

  bool firstEnter = false;

  Future<void> loadUser(UserModel user) async {
    userID = user.userID;
    firstEnter = true;

    isSeller = user.userType == UserType.SHOP;
  }

  Future<void> signOut() async {
    await PrefService.clearUserData();
    await PrefService.clearShopData();
  }

  bool isShop() {
    return isSeller;
  }
}