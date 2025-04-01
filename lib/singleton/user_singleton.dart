import 'package:pcplus/singleton/cart_singleton.dart';
import 'package:pcplus/singleton/shop_singleton.dart';

import '../models/items/item_model.dart';
import '../models/users/user_model.dart';
import '../objects/suggest_item_data.dart';

class UserSingleton {
  static UserSingleton? _instance;
  static UserSingleton getInstance() {
    _instance ??= UserSingleton();
    return _instance!;
  }

  UserModel? currentUser;

  List<ItemData> newestItems = [];
  List<ItemModel> newestItemsModel = [];

  bool firstEnter = true;

  bool isShop() {
    if (currentUser == null) {
      return false;
    }
    return currentUser!.isSeller!;
  }

  Future<void> loadUser(UserModel user) async {
    ShopSingleton shopSingleton = ShopSingleton.getInstance();
    // CartSingleton cartSingleton = CartSingleton.getInstance();

    currentUser = user;
    firstEnter = true;
    // if (user.isSeller!) {
    //   shopSingleton.changeShop(user);
    // } else {
    //   await cartSingleton.initCart();
    // }
  }

  Future<void> signOut() async {
    // CartSingleton cartSingleton = CartSingleton.getInstance();
    // cartSingleton.clearData();
  }
}