import '../items/item_model.dart';
import '../users/user_model.dart';
import 'in_cart_item_model.dart';

class ItemInCartWithSeller {

  ItemModel item;
  UserModel seller;
  InCartItemModel inCart;

  ItemInCartWithSeller({
    required this.item,
    required this.seller,
    required this.inCart
  });

}