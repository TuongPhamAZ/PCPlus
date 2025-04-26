import 'package:pcplus/builders/object_builders/list_item_data_builder.dart';
import 'package:pcplus/builders/object_builders/list_object_builder_director.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/home/user_home/home_contract.dart';
import 'package:pcplus/controller/api_controller.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/objects/suggest_item_data.dart';
import 'package:pcplus/services/test_tool.dart';
import 'package:pcplus/singleton/search_singleton.dart';
import 'package:pcplus/singleton/user_singleton.dart';
import 'package:pcplus/singleton/view_item_singleton.dart';

class HomePresenter {
  final HomeContract _view;
  HomePresenter(this._view);

  final ItemRepository _itemRepo = ItemRepository();
  final ApiController  _apiController = ApiController();
  //final AuthenticationService _auth = AuthenticationService();
  final SearchSingleton _searchSingleton = SearchSingleton.getInstance();
  final ViewItemSingleton _itemSingleton = ViewItemSingleton.getInstance();

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

    List<String> recommendedItemIds = await _apiController.callApiRecommend(SessionController.getInstance().userID!, MAX_RECOMMENDED_ITEMS);
    recommendedItemStream = _itemRepo.getItemsWithSellerStreamByIdList(recommendedItemIds);

    _view.onLoadDataSucceed();
  }

  Future<void> handleItemPressed(ItemWithSeller item) async {
    _view.onWaitingProgressBar();
    //await _itemSingleton.storeItemData(item);
    _view.onPopContext();
    _view.onItemPressed(item);
  }

  void handleSearch(String input) {
    if (input == "") {
      return;
    }

    _searchSingleton.needSearch = true;
    _searchSingleton.storedSearchInput = input;
    _view.onSearch();
  }
}