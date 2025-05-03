import 'package:pcplus/models/items/item_model.dart';

import '../shops/shop_model.dart';

class ItemWithSeller {
  ItemModel item;
  ShopModel seller;

  ItemWithSeller({
    required this.item,
    required this.seller
  });
}