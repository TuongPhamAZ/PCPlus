import 'package:flutter/material.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/await_ratings/await_rating_repo.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/ratings/rating_model.dart';
import 'package:pcplus/models/ratings/rating_repo.dart';
import 'package:pcplus/pages/rating/rating_contract.dart';
import '../../models/await_ratings/await_rating_model.dart';
import '../../models/items/item_model.dart';
import '../../services/utility.dart';

class RatingPresenter {
  final RatingScreenContract _view;
  RatingPresenter(this._view);

  final AwaitRatingRepository _awaitRatingRepo = AwaitRatingRepository();
  final SessionController _sessionController = SessionController.getInstance();
  final RatingRepository _ratingRepo = RatingRepository();
  final ItemRepository _itemRepo = ItemRepository();

  Stream<List<AwaitRatingModel>>? awaitRatingStream;

  Future<void> getData() async {
    awaitRatingStream = _awaitRatingRepo.getAllAwaitRatingStream(_sessionController.userID!);

    List<AwaitRatingModel> items = await _awaitRatingRepo.getAllAwaitRating(_sessionController.userID!);

    for (AwaitRatingModel item in items) {
      if (Utility.calculateDuration(item.createdAt!, DateTime.now()).inDays - 30 > 0) {
        await _awaitRatingRepo.deleteAwaitRatingByKey(SessionController.getInstance().userID!, item.key!);
      }
    }
  }

  Future<void> sendRating(AwaitRatingModel model, double rating, String? comment) async {
    _view.onWaitingProgressBar();
    RatingModel ratingModel = RatingModel(
        userID: _sessionController.userID,
        itemID: model.item!.itemID!,
        rating: rating,
        date: DateTime.now(),
        comment: comment ?? "",
        like: [],
        dislike: [],
    );
    await _ratingRepo.addRatingToFirestore(model.item!.itemID!, ratingModel);
    await _awaitRatingRepo.deleteAwaitRatingByKey(_sessionController.userID!, model.key!);
    await SessionController.getInstance().onRating(model.item!.itemID!, rating);
    ItemModel? itemModel = await _itemRepo.getItemById(model.item!.itemID!);
    if (itemModel != null) {
      double sumRating = itemModel.ratingCount! * itemModel.rating!;
      itemModel.ratingCount = itemModel.ratingCount! + 1;
      itemModel.rating = (sumRating + rating) / itemModel.ratingCount!;
      await _itemRepo.updateItem(itemModel);
    } else {
      debugPrint("Problem with Rating! Can't update Item rating");
    }

    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }
}