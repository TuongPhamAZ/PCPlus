import 'package:pcplus/builders/object_builders/list_object_builder_director.dart';
import 'package:pcplus/builders/object_builders/list_review_data_builder.dart';
import 'package:pcplus/models/interactions/interaction_model.dart';
import 'package:pcplus/models/interactions/interaction_repo.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/ratings/rating_repo.dart';
import 'package:pcplus/objects/review_data.dart';
import 'package:pcplus/objects/suggest_item_data.dart';
import 'package:pcplus/services/authentication_service.dart';

import '../models/ratings/rating_model.dart';

class ViewItemSingleton {
  static ViewItemSingleton? _instance;
  static ViewItemSingleton getInstance() {
    _instance ??= ViewItemSingleton();
    return _instance!;
  }

  final InteractionRepository _interactionRepo = InteractionRepository();
  final RatingRepository _ratingRepo = RatingRepository();
  final ItemRepository _itemRepo = ItemRepository();

  final AuthenticationService _auth = AuthenticationService();

  ItemData? itemData;
  InteractionModel? interaction;
  List<ReviewData> reviewsData = [];
  int shopProductsCount = 0;

  Future<void> storeItemData(ItemData data) async {
    reset();
    itemData = data;
    // interaction = await _interactionRepo.getInteractionsByUserIDAndItemID(
    //     _auth.userId!,
    //     itemData!.product!.itemID!
    // );
    List<RatingModel> ratings = await _ratingRepo.getAllRatingsByItemID(itemData!.product!.itemID!);

    List<ItemModel> shopProducts = await _itemRepo.getItemsBySeller(itemData!.product!.sellerID!);
    shopProductsCount = shopProducts.length;

    final ListObjectBuilderDirector director = ListObjectBuilderDirector();
    final ListReviewDataBuilder builder = ListReviewDataBuilder();

    await director.makeListReviewData(
        builder: builder,
        ratings: ratings,
    );

    reviewsData = builder.createList().cast();
  }

  void reset() {
    itemData = null;
    interaction = null;
    reviewsData.clear();
  }


}