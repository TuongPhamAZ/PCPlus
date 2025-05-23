import 'package:flutter/cupertino.dart';
import 'package:pcplus/interfaces/command.dart';
import 'package:pcplus/models/items/item_with_seller.dart';

import '../../pages/widgets/listItem/suggest_item.dart';

class SuggestItemFactory {
  static Widget create ({
    required ItemWithSeller itemWithSeller,
    required ICommand command,
  }) {
    return SuggestItem(
        itemName: itemWithSeller.item.name!,
        description: itemWithSeller.item.description!,
        imagePath: itemWithSeller.item.image!,
        command: command,
        location: itemWithSeller.seller.location!,
        rating: itemWithSeller.item.rating!,
        price: itemWithSeller.item.discountPrice!,
        sold: itemWithSeller.item.sold!
    );
  }
}