// ignore_for_file: unused_element, constant_identifier_names

import 'dart:async';
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
  final ApiController _apiController = ApiController();
  //final AuthenticationService _auth = AuthenticationService();

  static const MAX_NEWEST_ITEMS = 10;
  static const MAX_RECOMMENDED_ITEMS = 10;

  List<ItemData> newestItems = [];
  List<ItemData> recommendedItems = [];

  List<ItemModel> newestItemsModel = [];
  List<ItemModel> recommendedItemsModel = [];
  Map<String, UserModel> cacheShop = {};

  // StreamController để quản lý stream lifecycle
  StreamController<List<ItemWithSeller>>? _newestItemController;
  StreamController<List<ItemWithSeller>>? _recommendedItemController;

  // Stream subscriptions để dispose
  StreamSubscription<List<ItemWithSeller>>? _newestItemSubscription;
  StreamSubscription<List<ItemWithSeller>>? _recommendedItemSubscription;

  Stream<List<ItemWithSeller>>? get newestItemStream =>
      _newestItemController?.stream;
  Stream<List<ItemWithSeller>>? get recommendedItemStream =>
      _recommendedItemController?.stream;

  bool _isDisposed = false;

  Future<void> getData() async {
    if (_isDisposed) return;

    // Dispose existing streams if any
    await _disposeStreams();

    // Create new controllers
    _newestItemController = StreamController<List<ItemWithSeller>>.broadcast();
    _recommendedItemController =
        StreamController<List<ItemWithSeller>>.broadcast();

    // Subscribe to repository streams
    _newestItemSubscription = _itemRepo
        .getNewestItemsWithSellerStream(MAX_NEWEST_ITEMS)
        .listen((data) {
      if (!_isDisposed && !_newestItemController!.isClosed) {
        _newestItemController!.add(data);
      }
    }, onError: (error) {
      if (!_isDisposed && !_newestItemController!.isClosed) {
        _newestItemController!.addError(error);
      }
    });

    _recommendedItemSubscription =
        _getRecommendedItemsAsStream().listen((data) {
      if (!_isDisposed && !_recommendedItemController!.isClosed) {
        _recommendedItemController!.add(data);
      }
    }, onError: (error) {
      if (!_isDisposed && !_recommendedItemController!.isClosed) {
        _recommendedItemController!.addError(error);
      }
    });

    _view.onLoadDataSucceed();
  }

  Stream<List<ItemWithSeller>> _getRecommendedItemsAsStream() async* {
    List<String> recommendedItemIds = await _apiController.callApiRecommend(
        SessionController.getInstance().userID!, MAX_RECOMMENDED_ITEMS);
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

    _view.onSearch(input);
  }

  // Dispose streams khi không sử dụng nữa
  Future<void> _disposeStreams() async {
    await _newestItemSubscription?.cancel();
    await _recommendedItemSubscription?.cancel();

    await _newestItemController?.close();
    await _recommendedItemController?.close();

    _newestItemSubscription = null;
    _recommendedItemSubscription = null;
    _newestItemController = null;
    _recommendedItemController = null;
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _disposeStreams();
  }
}
