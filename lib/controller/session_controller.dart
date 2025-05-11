
import 'package:pcplus/models/shops/shop_repo.dart';
import 'package:pcplus/services/pref_service.dart';

import '../models/shops/shop_model.dart';
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

  final ShopRepository _shopRepository = ShopRepository();

  Future<void> loadUser(UserModel user) async {
    userID = user.userID;
    firstEnter = true;

    isSeller = user.userType == UserType.SHOP;

    if (isSeller) {
      ShopModel shop = await _shopRepository.getShopById(userID!);
      await PrefService.saveShopData(shopData: shop);
    }
  }

  Future<void> signOut() async {
    await PrefService.clearUserData();
    await PrefService.clearShopData();
  }

  bool isShop() {
    return isSeller;
  }
}