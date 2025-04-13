import 'package:pcplus/models/interactions/interaction_repo.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/ratings/rating_repo.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/objects/data_object_interface.dart';

class ItemData extends IDataObject {
  ItemModel? product;
  UserModel? shop;
  double? rating;

  ItemData({
    this.product,
    this.shop,
    this.rating,
  });

  Future<void> loadRating() async {
    final RatingRepository ratingRepository = RatingRepository();
    if (product != null) {
      rating = await ratingRepository.getRatingValueByItemID(product!.itemID!);
    }
  }
}