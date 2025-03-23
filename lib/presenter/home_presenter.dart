import 'package:pcplus/builders/object_builders/list_item_data_builder.dart';
import 'package:pcplus/builders/object_builders/list_object_builder_director.dart';
import 'package:pcplus/contract/home_contract.dart';
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
  final UserSingleton _userSingleton = UserSingleton.getInstance();

  static const MAX_NEWEST_ITEMS = 10;
  static const MAX_RECOMMENDED_ITEMS = 10;

  List<ItemData> newestItems = [];
  List<ItemData> recommendedItems = [];

  List<ItemModel> newestItemsModel = [];
  List<ItemModel> recommendedItemsModel = [];
  Map<String, UserModel> cacheShop = {};

  Future<void> getData() async {
    final ListItemDataBuilder builder = ListItemDataBuilder();
    final Map<String, UserModel> cacheShops = {};
    final ListObjectBuilderDirector director = ListObjectBuilderDirector();

    final TestTool testTool = TestTool();
    List<ItemModel> newestItemModels = await _itemRepo.getTopItems(MAX_NEWEST_ITEMS);
    // List<ItemModel> newestItemModels = testTool.getRandomItemModelList(10);

    await director.makeListItemData(
        builder: builder,
        items: newestItemModels,
        shops: cacheShops
    );
    newestItems = builder.createList().cast<ItemData>();

    // List<String> itemIds = await _apiController.callApiRecommend("5235448", MAX_RECOMMENDED_ITEMS);
    // print(itemIds);
    // for (String itemId in itemIds) {
    //   recommendedItems.add(await _itemRepo.getItemById(itemId));
    // }
    List<ItemModel> recommendItemModels = await _itemRepo.getRandomItems(20);
    await director.makeListItemData(
        builder: builder,
        items: recommendItemModels,
        shops: cacheShops
    );
    recommendedItems = builder.createList().cast<ItemData>();

    _view.onLoadDataSucceed();
  }

  Future<void> handleItemPressed(ItemData item) async {
    _view.onWaitingProgressBar();
    await _itemSingleton.storeItemData(item);
    _view.onPopContext();
    _view.onItemPressed();
  }

  void handleSearch(String input) {
    _searchSingleton.needSearch = true;
    _searchSingleton.storedSearchInput = input;
    _view.onSearch();
  }
}