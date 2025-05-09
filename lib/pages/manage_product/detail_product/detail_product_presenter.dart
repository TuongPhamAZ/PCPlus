import 'dart:collection';

import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_model.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_repo.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/models/ratings/rating_repo.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product_contract.dart';

import '../../../models/items/item_model.dart';
import '../../../models/ratings/rating_model.dart';
import '../../../models/users/user_model.dart';
import '../../../objects/review_data.dart';

class DetailProductPresenter {
  final DetailProductContract _view;
  DetailProductPresenter(this._view);

  final RatingRepository _ratingRepo = RatingRepository();
  final ItemRepository _itemRepo = ItemRepository();
  final UserRepository _userRepo = UserRepository();
  final InCartItemRepo _inCartItemRepo = InCartItemRepo();

  ItemWithSeller? itemWithSeller;
  List<RatingModel> ratings = [];

  List<ReviewData> ratingsData = [];
  int shopProductsCount = 0;

  Future<void> getData() async {
    ratings.clear();
    ratingsData.clear();

    List<ItemModel> sellerProducts = await _itemRepo.getItemsBySeller(itemWithSeller!.seller.shopID!);
    shopProductsCount = sellerProducts.length;

    ratings = await _ratingRepo.getAllRatingsByItemID(itemWithSeller!.item.itemID!);

    Map<String, UserModel?> users = {};
    for (RatingModel rating in ratings) {
      users[rating.userID!] = null;
    }

    List<UserModel> userModels = await _userRepo.getAllUsersByIdList(users.keys.toList());

    for (UserModel model in userModels) {
      users[model.userID!] = model;
    }

    for (RatingModel rating in ratings) {
      ratingsData.add(ReviewData(
        rating: rating,
        user: users[rating.userID!]
      ));
    }

    _view.onLoadDataSucceeded();
  }

  void handleBack() {
    _view.onBack();
  }

  Future<void> handleViewShop() async {
    // _view.onWaitingProgressBar();
    // _shopSingleton.changeShop(_itemSingleton.itemData!.shop!);
    // await _shopSingleton.initShopData();
    // _view.onPopContext();
    _view.onViewShop(itemWithSeller!.seller.shopID!);
  }

  Future<void> handleAddToCart() async {
    // _cartSingleton.addItemToCart(
    //     itemData: _itemSingleton.itemData!,
    //     colorIndex: 0,
    //     amount: 1
    // );
    _view.onWaitingProgressBar();

    String userId = SessionController.getInstance().userID!;
    String itemId = itemWithSeller!.item.itemID!;

    InCartItemModel? temp = await _inCartItemRepo.getItemInCartByItemID(userId, itemId);

    if (temp == null) {
      InCartItemModel model = InCartItemModel(
        itemID: itemWithSeller!.item.itemID!,
        color: itemWithSeller!.item.colors!.first,
        amount: 1,
        isSelected: false,
      );

       await _inCartItemRepo.addItemToUserCart(userId, model);
    }

    _view.onPopContext();
    _view.onAddToCart();
  }

  Future<void> handleBuyNow({
    required int colorIndex,
    required int amount
  }) async {
    _view.onWaitingProgressBar();

    String userId = SessionController.getInstance().userID!;
    String itemId = itemWithSeller!.item.itemID!;
    ItemModel? itemTemp = await _itemRepo.getItemById(itemId);
    if (itemTemp == null) {
      _view.onPopContext();
      _view.onError("Có lỗi xảy ra. Hãy thử lại sau.");
      return;
    } else if (itemTemp.stock! < amount) {
      _view.onPopContext();
      _view.onError("Sản phẩm này hiện không mua được");
      return;
    }

    await _inCartItemRepo.selectAllItemInCart(userId, false);

    InCartItemModel? inCartItemTemp = await _inCartItemRepo.getItemInCartByItemID(userId, itemId);
    if (inCartItemTemp == null) {
      inCartItemTemp = InCartItemModel(
        itemID: itemWithSeller!.item.itemID!,
        color: itemWithSeller!.item.colors!.first,
        amount: 1,
        isSelected: true,
      );

      await _inCartItemRepo.addItemToUserCart(userId, inCartItemTemp);
    }
    else {
      inCartItemTemp.color = itemWithSeller!.item.colors![colorIndex];
      inCartItemTemp.amount = amount;
      inCartItemTemp.isSelected = true;
      await _inCartItemRepo.updateItemInCart(userId, inCartItemTemp);
    }

    _view.onPopContext();
    _view.onBuyNow();
  }
}