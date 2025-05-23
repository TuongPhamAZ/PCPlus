import 'package:pcplus/interfaces/command.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import '../../pages/widgets/listItem/new_item.dart';

class NewItemFactory {
  static NewItem create ({
    required ItemWithSeller itemWithSeller,
    required ICommand command
  }) {
    return NewItem(
        itemName: itemWithSeller.item.name!,
        imagePath: itemWithSeller.item.image!,
        command: command,
        location: itemWithSeller.seller.location!,
        rating: itemWithSeller.item.rating!,
        price: itemWithSeller.item.discountPrice!,
        sold: itemWithSeller.item.sold!
    );
  }
}