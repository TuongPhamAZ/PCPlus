import 'package:flutter/cupertino.dart';
import 'package:pcplus/const/order_status.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/factories/widget_factories/history_order_item_factory.dart';
import 'package:pcplus/models/orders/order_model.dart';
import 'package:pcplus/models/orders/order_repo.dart';
import 'package:pcplus/services/notification_service.dart';
import 'package:pcplus/services/pref_service.dart';
import '../../models/users/user_model.dart';
import 'history_order_contract.dart';

class HistoryOrderPresenter {
  final HistoryOrderContract _view;
  final String orderType;
  HistoryOrderPresenter(
    this._view, {
    required this.orderType
  });

  final OrderRepository _orderRepo = OrderRepository();
  final SessionController _sessionController = SessionController.getInstance();
  final NotificationService _notificationService = NotificationService();
  UserModel? user;

  List<OrderModel> orders = [];

  bool get isShop => _sessionController.isShop();

  Stream<List<OrderModel>>? orderStream;

  Future<void> getData() async {
    user = await PrefService.loadUserData();

    if (orderType.isEmpty) {
      orderStream = _orderRepo.getAllOrdersFromUserStream(user!.userID!);
    } else {
      orderStream = _orderRepo.getAllOrdersFromUserByStatusStream(user!.userID!, orderType);
    }
    _view.onLoadDataSucceeded();
  }

  Widget createHistoryOrderItem(OrderModel order) {
    if (isShop) {
      switch (orderType) {
        case OrderStatus.PENDING_CONFIRMATION:
          return FactoryOrderItemFactory.createNeedConfirmOrderWidget(this, order);
        case OrderStatus.AWAIT_PICKUP:
          return FactoryOrderItemFactory.createSentOrderWidget(this, order);
        case OrderStatus.AWAIT_DELIVERY:
          return FactoryOrderItemFactory.createNormalOrderWidget(this, order);
        case OrderStatus.AWAIT_RATING:
          return FactoryOrderItemFactory.createNormalOrderWidget(this, order);
        case OrderStatus.COMPLETED:
          return FactoryOrderItemFactory.createNormalOrderWidget(this, order);
        default:
          return FactoryOrderItemFactory.createNormalOrderWidget(this, order);
      }
    } else {
      switch (orderType) {
        case OrderStatus.PENDING_CONFIRMATION:
          return FactoryOrderItemFactory.createNormalOrderWidget(this, order);
        case OrderStatus.AWAIT_PICKUP:
          return FactoryOrderItemFactory.createCanCancelOrderWidget(this, order);
        case OrderStatus.AWAIT_DELIVERY:
          return FactoryOrderItemFactory.createConfirmReceivedOrderWidget(this, order);         break;
        case OrderStatus.AWAIT_RATING:
          return FactoryOrderItemFactory.createNormalOrderWidget(this, order);
        case OrderStatus.COMPLETED:
          return FactoryOrderItemFactory.createNormalOrderWidget(this, order);
        default:
          return FactoryOrderItemFactory.createNormalOrderWidget(this, order);
      }
    }
  }

  void updateOrder(OrderModel model, String status) {
    model.status = status;
    _orderRepo.updateOrder(model.receiverID!, model);
    _orderRepo.updateOrder(model.itemModel!.sellerID!, model);
  }

  Future<void> handleCancelOrder(OrderModel model, String reason) async {
    _view.onWaitingProgressBar();
    updateOrder(model, OrderStatus.CANCELLED);
    if (isShop) {
      await _notificationService.createShopCancelOrderingNotification(model, reason);
    } else {
      await _notificationService.createCancelOrderingNotification(model, reason);
    }

    if (orderType.isNotEmpty) {
      orders.remove(model);
    }
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }

  Future<void> handleAlreadyReceivedOrder(OrderModel model) async {
    _view.onWaitingProgressBar();
    updateOrder(model, OrderStatus.AWAIT_RATING);
    await _notificationService.createReceivedOrderNotification(model);

    if (orderType.isNotEmpty) {
      orders.remove(model);
    }
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }

  Future<void> handleConfirmOrder(OrderModel model) async {
    _view.onWaitingProgressBar();
    updateOrder(model, OrderStatus.AWAIT_PICKUP);
    await _notificationService.createShopConfirmOrderNotification(model);

    if (orderType.isNotEmpty) {
      orders.remove(model);
    }
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }

  Future<void> handleSentOrder(OrderModel model) async {
    _view.onWaitingProgressBar();
    updateOrder(model, OrderStatus.AWAIT_DELIVERY);
    await _notificationService.createShopSentOrderNotification(model);
    if (orderType.isNotEmpty) {
      orders.remove(model);
    }
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }
}