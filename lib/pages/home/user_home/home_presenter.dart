import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/home/user_home/home_contract.dart';
import 'package:pcplus/controller/api_controller.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/objects/suggest_item_data.dart';

import '../../../controller/session_controller.dart';

class HomePresenter {
  final HomeContract _view;
  HomePresenter(this._view);

  final ItemRepository _itemRepo = ItemRepository();
  final ApiController  _apiController = ApiController();
  //final AuthenticationService _auth = AuthenticationService();

  static const MAX_NEWEST_ITEMS = 10;
  static const MAX_RECOMMENDED_ITEMS = 10;

  List<ItemData> newestItems = [];
  List<ItemData> recommendedItems = [];

  List<ItemModel> newestItemsModel = [];
  List<ItemModel> recommendedItemsModel = [];
  Map<String, UserModel> cacheShop = {};

  Stream<List<ItemWithSeller>>? newestItemStream;
  Stream<List<ItemWithSeller>>? recommendedItemStream;

  Future<void> getData() async {
    newestItemStream = _itemRepo.getNewestItemsWithSellerStream(MAX_NEWEST_ITEMS);
    recommendedItemStream = _itemRepo.getNewestItemsWithSellerStream(MAX_NEWEST_ITEMS);
    // recommendedItemStream = _getRecommendedItemsAsStream();

    _view.onLoadDataSucceed();
  }

  Stream<List<ItemWithSeller>> _getRecommendedItemsAsStream() async* {
    List<String> recommendedItemIds = await _apiController.callApiRecommend(SessionController.getInstance().userID!, MAX_RECOMMENDED_ITEMS);
    yield* _itemRepo.getItemsWithSellerStreamByIdList(recommendedItemIds);
  }

  Future<void> handleItemPressed(ItemWithSeller item) async {
    _view.onWaitingProgressBar();
    _view.onPopContext();
    _view.onItemPressed(item);
  }

  void handleSearch(String input) {
    if (input == "") {
      return;
    }

    _view.onSearch();
  }
}