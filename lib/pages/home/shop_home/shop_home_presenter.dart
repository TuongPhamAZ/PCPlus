import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/shops/shop_repo.dart';
import 'package:pcplus/pages/home/shop_home/shop_home_contract.dart';
import 'package:pcplus/services/pref_service.dart';
import '../../../models/items/item_with_seller.dart';
import '../../../models/shops/shop_model.dart';

class ShopHomePresenter {
  final ShopHomeContract _view;
  ShopHomePresenter(this._view);

  final SessionController _sessionController = SessionController.getInstance();
  final ItemRepository _itemRepo = ItemRepository();
  // final UserRepository _userRepo = UserRepository();
  final ShopRepository _shopRepo = ShopRepository();

  String? userId;
  ShopModel? seller;

  // List<ItemModel> itemModels = [];
  // List<ItemData> itemsData = [];

  Stream<List<ItemWithSeller>>? userItemsStream;

  Future<void> getData() async {
    // await _shopSingleton.initShopData();
    // await _shopSingleton.initShopData();
    // if (_userSingleton.firstEnter) {
    //
    //   _userSingleton.firstEnter = false;
    // } else {
    //
    // }

    if (_sessionController.isShop()) {
      userId = _sessionController.userID;
      seller = await PrefService.loadShopData();
    }
    else {
      seller = await _shopRepo.getShopById(userId!);
    }

    userItemsStream = _itemRepo.getItemsWithSellerStreamBySellerID(userId!);

    _view.onLoadDataSucceeded();
  }

  Future<void> handleItemEdit(ItemWithSeller itemData) async {
    // _shopSingleton.editedItem = itemData;
    _view.onItemEdit(itemData);
  }

  Future<void> handleItemDelete(ItemWithSeller itemData) async {
    // await _shopSingleton.deleteData(itemData);
    _view.onWaitingProgressBar();
    await _itemRepo.deleteItemById(itemData.item.itemID!);
    _view.onPopContext();
    _view.onItemDelete();
  }

  // void dispose() {
  //   _shopSingleton.unsubscribe(this);
  // }

  // @override
  // void updateSubscriber() {
  //   // TODO: implement updateSubscriber
  //   itemModels = _shopSingleton.itemModels;
  //   itemsData = _shopSingleton.itemsData;
  //   _view.onFetchDataSucceeded();
  // }

  Future<void> handleItemPressed(ItemWithSeller item) async {
    // _view.onWaitingProgressBar();
    // await _itemSingleton.storeItemData(item);
    // _view.onPopContext();
    _view.onItemPressed(item);
  }

  void handleBack() {
    _view.onBack();
  }
}