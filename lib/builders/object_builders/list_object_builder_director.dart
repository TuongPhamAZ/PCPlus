import 'package:pcplus/builders/object_builders/list_item_data_builder.dart';
import 'package:pcplus/models/users/user_model.dart';

import '../../models/items/item_model.dart';
import '../../models/ratings/rating_model.dart';
import 'list_review_data_builder.dart';

class ListObjectBuilderDirector {
  Future<void> makeListItemData({
    required ListItemDataBuilder builder,
    required List<ItemModel> items,
    required Map<String, UserModel> shops
  }) async {
    builder.reset();
    builder.setItemList(items);
    builder.setShopCache(shops);
    await builder.build();
  }

  Future<void> makeListReviewData({
    required ListReviewDataBuilder builder,
    required List<RatingModel> ratings,
  }) async {
    builder.reset();
    builder.setRatingList(ratings);
    await builder.build();
  }
}