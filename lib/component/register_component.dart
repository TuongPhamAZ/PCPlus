import '../models/shops/shop_model.dart';
import '../models/users/user_model.dart';

class RegisterArgument {
  String? email;
  String? password;
  UserModel? userModel;
  ShopModel? shopModel;
  String? userType;

  RegisterArgument({
    required this.email,
    required this.userModel,
    required this.shopModel,
    required this.userType,
  });
}