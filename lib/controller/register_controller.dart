
import '../models/shops/shop_model.dart';
import '../models/users/user_model.dart';

class RegisterController {
  static RegisterController? _registerController;
  static getInstance() {
    _registerController ??= RegisterController();
    return _registerController;
  }

  RegisterController();

  String? email;
  UserModel? user;
  ShopModel? shop;

  void reset() {
    user = null;
    shop = null;
    email = null;
  }
}