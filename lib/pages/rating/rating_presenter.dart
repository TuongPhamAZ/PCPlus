import 'package:flutter/material.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/await_ratings/await_rating_repo.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/ratings/rating_model.dart';
import 'package:pcplus/models/ratings/rating_repo.dart';
import 'package:pcplus/models/shops/shop_repo.dart';
import 'package:pcplus/pages/rating/rating_contract.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import '../../models/await_ratings/await_rating_model.dart';
import '../../models/items/item_model.dart';
import '../../models/shops/shop_model.dart';
import '../../services/utility.dart';

class RatingPresenter {
  final RatingScreenContract _view;
  RatingPresenter(this._view);

  final AwaitRatingRepository _awaitRatingRepo = AwaitRatingRepository();
  final SessionController _sessionController = SessionController.getInstance();
  final RatingRepository _ratingRepo = RatingRepository();
  final ItemRepository _itemRepo = ItemRepository();
  final ShopRepository _shopRepo = ShopRepository();

  // StreamController để quản lý lifecycle
  StreamController<List<AwaitRatingModel>>? _awaitRatingController;
  StreamSubscription<List<AwaitRatingModel>>? _awaitRatingSubscription;

  // Getter cho stream
  Stream<List<AwaitRatingModel>>? get awaitRatingStream =>
      _awaitRatingController?.stream;

  bool _isDisposed = false;

  Future<void> getData() async {
    if (_isDisposed) return;

    // Khởi tạo controller nếu chưa có
    _awaitRatingController ??= StreamController<List<AwaitRatingModel>>();

    // Lắng nghe stream từ repository
    _awaitRatingSubscription = _awaitRatingRepo
        .getAllAwaitRatingStream(_sessionController.userID!)
        .listen(
      (data) {
        if (!_isDisposed && !_awaitRatingController!.isClosed) {
          _awaitRatingController!.add(data);
        }
      },
      onError: (error) {
        if (!_isDisposed && !_awaitRatingController!.isClosed) {
          _awaitRatingController!.addError(error);
        }
      },
    );

    List<AwaitRatingModel> items =
        await _awaitRatingRepo.getAllAwaitRating(_sessionController.userID!);

    for (AwaitRatingModel item in items) {
      if (Utility.calculateDuration(item.createdAt!, DateTime.now()).inDays -
              30 >
          0) {
        await _awaitRatingRepo.deleteAwaitRatingByKey(
            SessionController.getInstance().userID!, item.key!);
      }
    }
    _view.onLoadDataSucceeded();
  }

  Future<void> sendRating(
      AwaitRatingModel model, double rating, String? comment) async {
    if (_view.submitComment(comment) == false) return;

    _view.onWaitingProgressBar();

    RatingModel? ratingModel = await _ratingRepo.getRatingByUserIDAndItemID(_sessionController.userID!, model.item!.itemID!);

    bool isNewRating = true;
    if (ratingModel == null) {
      // Chưa có rating
      ratingModel = RatingModel(
        userID: _sessionController.userID,
        itemID: model.item!.itemID!,
        rating: rating,
        date: DateTime.now(),
        comment: comment ?? "",
        like: [],
        dislike: [],
      );
      await _ratingRepo.addRatingToFirestore(model.item!.itemID!, ratingModel);
    } else {
      // Đã có rating, cập nhật lại
      isNewRating = false;
    }

    await _awaitRatingRepo.deleteAwaitRatingByKey(
        _sessionController.userID!, model.key!);
    await SessionController.getInstance().onRating(model.item!.itemID!, rating);
    ItemModel? itemModel = await _itemRepo.getItemById(model.item!.itemID!);
    if (itemModel != null) {
      if (isNewRating) {
        // rating mới, thêm rating
        double sumRating = itemModel.ratingCount! * itemModel.rating!;
        itemModel.ratingCount = itemModel.ratingCount! + 1;
        itemModel.rating = (sumRating + rating) / itemModel.ratingCount!;
      } else {
        // cập nhật rating
        double sumRating = itemModel.ratingCount! * itemModel.rating!;
        itemModel.rating = (sumRating - ratingModel.rating! + rating) / itemModel.ratingCount!;
      }
      await _itemRepo.updateItem(itemModel);
    } else {
      _view.onPopContext();
      debugPrint("Problem with Rating! Can't update Item rating");
      return;
    }
    // Cập nhật rating của shop
    ShopModel? shopModel = await _shopRepo.getShopById(model.item!.sellerID!);
    if (shopModel != null) {
      if (isNewRating) {
        // Rating mới
        shopModel.ratingCount = shopModel.ratingCount! + 1;
        shopModel.rating =
            (shopModel.rating! * (shopModel.ratingCount! - 1) + rating) /
                shopModel.ratingCount!;
      } else {
        // Cập nhật lại rating
        shopModel.rating =
            (shopModel.rating! * shopModel.ratingCount! + rating) /
                shopModel.ratingCount!;
      }
      await _shopRepo.updateShop(shopModel);
    } else {
      _view.onPopContext();
      debugPrint("Problem with Rating! Can't update Item rating");
      return;
    }
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _disposeStreams();
  }

  Future<void> _disposeStreams() async {
    await _awaitRatingSubscription?.cancel();
    _awaitRatingSubscription = null;

    if (_awaitRatingController != null && !_awaitRatingController!.isClosed) {
      await _awaitRatingController!.close();
    }
    _awaitRatingController = null;
  }
}
