import 'package:flutter/cupertino.dart';
import 'package:pcplus/const/order_status.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/factories/widget_factories/history_order_item_factory.dart';
import 'package:pcplus/models/await_ratings/await_rating_model.dart';
import 'package:pcplus/models/await_ratings/await_rating_repo.dart';
import 'package:pcplus/models/bills/bill_of_shop_repo.dart';
import 'package:pcplus/models/bills/bill_repo.dart';
import 'package:pcplus/models/bills/bill_shop_item_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/services/notification_service.dart';
import 'package:pcplus/services/pref_service.dart';
import '../../factories/widget_factories/history_order_item_for_shop_factory.dart';
import '../../models/bills/bill_model.dart';
import '../../models/bills/bill_of_shop_model.dart';
import '../../models/shops/shop_model.dart';
import '../../models/users/user_model.dart';
import 'history_order_contract.dart';

class HistoryOrderPresenter {
  final HistoryOrderContract _view;
  final String orderType;
  HistoryOrderPresenter(
    this._view, {
    required this.orderType
  });

  // final OrderRepository _orderRepo = OrderRepository();
  final BillRepository _billRepo = BillRepository();
  final BillOfShopRepository _billOfShopRepo = BillOfShopRepository();
  final AwaitRatingRepository _awaitRatingRepo = AwaitRatingRepository();
  final SessionController _sessionController = SessionController.getInstance();
  final NotificationService _notificationService = NotificationService();
  final UserRepository _userRepo = UserRepository();
  UserModel? user;
  ShopModel? shop;

  // List<OrderModel> orders = [];
  List<BillModel> bills = [];
  List<BillOfShopModel> billOfShops = [];

  bool get isShop => _sessionController.isShop();
  String? shopName;

  // Stream<List<OrderModel>>? orderStream;
  Stream<List<BillModel>>? billStream;
  Stream<List<BillOfShopModel>>? billsOfShopStream;

  Future<void> getData() async {
    user = await PrefService.loadUserData();

    if (isShop) {
      shop = await PrefService.loadShopData();
      billsOfShopStream = _billOfShopRepo.getAllBillsOfShopFromShopStream(user!.userID!);
    }
    else {
      billStream = _billRepo.getAllBillsFromUserStream(user!.userID!);
    }

    _view.onLoadDataSucceeded();
  }

  Widget? createHistoryOrderItemForUser(BillModel order, String shopID) {

    String type = orderType.isNotEmpty ? orderType : order.getBillShopModel(shopID)!.status!;

    switch (type) {
      case OrderStatus.PENDING_CONFIRMATION:
        return OrderItemFactory.createNormalOrderWidget(this, order, shopID);
      case OrderStatus.AWAIT_PICKUP:
        return OrderItemFactory.createCanCancelOrderWidget(this, order, shopID);
      case OrderStatus.AWAIT_DELIVERY:
        return OrderItemFactory.createConfirmReceivedOrderWidget(this, order, shopID);
      case OrderStatus.AWAIT_RATING:
        return OrderItemFactory.createNormalOrderWidget(this, order, shopID);
      case OrderStatus.COMPLETED:
        return OrderItemFactory.createNormalOrderWidget(this, order, shopID);
      default:
        return OrderItemFactory.createNormalOrderWidget(this, order, shopID);
    }
  }

  Widget? createHistoryOrderItemForShop(BillOfShopModel order) {
    String shopName = shop!.name!;

    String type = orderType.isNotEmpty ? orderType : order.status!;

    switch (type) {
      case OrderStatus.PENDING_CONFIRMATION:
        return OrderItemForShopFactory.createNeedConfirmOrderWidget(this, order, shopName);
      case OrderStatus.AWAIT_PICKUP:
        return OrderItemForShopFactory.createSentOrderWidget(this, order, shopName);
      case OrderStatus.AWAIT_DELIVERY:
        return OrderItemForShopFactory.createNormalOrderWidget(this, order, shopName);
      case OrderStatus.AWAIT_RATING:
        return OrderItemForShopFactory.createNormalOrderWidget(this, order, shopName);
      case OrderStatus.COMPLETED:
        return OrderItemForShopFactory.createNormalOrderWidget(this, order, shopName);
      default:
        return OrderItemForShopFactory.createNormalOrderWidget(this, order, shopName);
    }
  }

  Future<bool> updateOrder(BillModel model, String shopID, String status) async {
    model.updateShopStatus(shopID, status);
    await _billRepo.updateBill(model.userID!, model);

    BillOfShopModel? billOfShopModel = model.toBillOfShopModel(shopID);

    if (billOfShopModel == null) {
      return false;
    }

    await _billOfShopRepo.updateBillOfShop(shopID, billOfShopModel);

    return true;
  }

  Future<void> handleCancelOrder(BillModel model, String shopID, String reason) async {
    _view.onWaitingProgressBar();

    if (await updateOrder(model, shopID, OrderStatus.CANCELLED) == false) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }

    BillOfShopModel? billOfShopModel = model.toBillOfShopModel(shopID);
    if (billOfShopModel == null) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }
    await _notificationService.createCancelOrderingNotification(shopID, billOfShopModel, reason);

    if (orderType.isNotEmpty) {
      bills.remove(model);
    }

    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }

  Future<void> handleCancelOrderForShop(BillOfShopModel model, String reason) async {
    _view.onWaitingProgressBar();

    BillModel? billModel = await _billRepo.getBill(model.userID!, shop!.shopID!);
    if (billModel == null) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }
    if (await updateOrder(billModel, shop!.shopID!, OrderStatus.CANCELLED) == false) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }

    if (orderType.isNotEmpty) {
      billOfShops.remove(model);
    }

    await _notificationService.createShopCancelOrderingNotification(model, shop!.name!, reason);

    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }

  Future<void> handleAlreadyReceivedOrder(BillModel model, String shopID) async {
    _view.onWaitingProgressBar();
    if (await updateOrder(model, shopID, OrderStatus.COMPLETED) == false) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }

    BillOfShopModel? billOfShopModel = model.toBillOfShopModel(shopID);
    if (billOfShopModel == null) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }
    // Cộng tiền cho shop
    UserModel? sellerModel = await _userRepo.getUserById(shopID);
    if (sellerModel != null) {
      sellerModel.money = sellerModel.money! + billOfShopModel.payout!;
      await _userRepo.updateUser(sellerModel);
    } else {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }

    // Gửi thông báo
    await _notificationService.createReceivedOrderNotification(shopID, billOfShopModel);

    for (BillShopItemModel billShopItem in billOfShopModel.items!) {
      AwaitRatingModel awaitRatingModel = billShopItem.createAwaitRatingModel(model.getBillShopModel(shopID)!.shopName!);
      await _awaitRatingRepo.addAwaitRatingToFirestore(billOfShopModel.userID!, awaitRatingModel);
    }

    if (orderType.isNotEmpty) {
      bills.remove(model);
    }
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }

  Future<void> handleConfirmOrderForShop(BillOfShopModel model) async {
    _view.onWaitingProgressBar();

    BillModel? billModel = await _billRepo.getBill(model.userID!, model.billID!);
    if (billModel == null) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }
    if (await updateOrder(billModel, shop!.shopID!, OrderStatus.AWAIT_PICKUP) == false) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }

    await _notificationService.createShopConfirmOrderNotification(model, shop!.name!);

    if (orderType.isNotEmpty) {
      billOfShops.remove(model);
    }
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }

  Future<void> handleSentOrderForShop(BillOfShopModel model) async {
    _view.onWaitingProgressBar();

    BillModel? billModel = await _billRepo.getBill(model.userID!, model.billID!);
    if (billModel == null) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }
    if (await updateOrder(billModel, shop!.shopID!, OrderStatus.AWAIT_DELIVERY) == false) {
      _view.onPopContext();
      _view.onError("Đã có lỗi xảy ra. Hãy thử lại sau.");
      return;
    }

    await _notificationService.createShopSentOrderNotification(model, shop!.name!);

    if (orderType.isNotEmpty) {
      billOfShops.remove(model);
    }
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }
}