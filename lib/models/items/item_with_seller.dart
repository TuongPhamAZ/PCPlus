import 'package:pcplus/models/items/item_model.dart';

import '../users/user_model.dart';

class ItemWithSeller {
  ItemModel item;
  UserModel seller;

  ItemWithSeller({
    required this.item,
    required this.seller
  });
}