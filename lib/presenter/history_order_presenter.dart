import 'package:pcplus/const/order_status.dart';
import 'package:pcplus/contract/history_order_contract.dart';
import 'package:pcplus/models/notification/notification_repo.dart';
import 'package:pcplus/models/orders/order_model.dart';
import 'package:pcplus/models/orders/order_repo.dart';
import 'package:pcplus/services/notification_service.dart';
import 'package:pcplus/singleton/user_singleton.dart';
import 'package:pcplus/strategy/history_order/confirm_received_order_build_strategy.dart';
import 'package:pcplus/strategy/history_order/history_order_strategy.dart';
import 'package:pcplus/strategy/history_order/need_confirm_order_build_strategy.dart';
import 'package:pcplus/strategy/history_order/normal_order_build_strategy.dart';
import 'package:pcplus/strategy/history_order/sent_order_build_strategy.dart';

import '../models/users/user_model.dart';
import '../strategy/history_order/can_cancel_order_build_strategy.dart';
import '../strategy/history_order/mix_order_build_strategy.dart';

class HistoryOrderPresenter {
  final HistoryOrderContract _view;
  final String orderType;
  HistoryOrderPresenter(
    this._view, {
    required this.orderType
  });

  final OrderRepository _orderRepo = OrderRepository();
  final UserSingleton _userSingleton = UserSingleton.getInstance();
  final NotificationService _notificationService = NotificationService();
  UserModel? get user => _userSingleton.currentUser;

  List<OrderModel> orders = [];
  bool get isShop => _userSingleton.isShop();

  Future<void> getData() async {
    if (orderType.isEmpty) {
      orders = await _orderRepo.getAllOrdersFromUser(user!.userID!);
    } else {
      orders = await _orderRepo.getAllOrdersFromUserByStatus(user!.userID!, orderType);
    }
    _view.onLoadDataSucceeded();
  }

  HistoryOrderBuildListStrategy? createBuildOrderStrategy() {
    HistoryOrderBuildListStrategy? strategy;
    if (isShop) {
      switch (orderType) {
        case OrderStatus.PENDING_CONFIRMATION:
          strategy = NeedConfirmOrdersBuildStrategy(this);
          break;
        case OrderStatus.AWAIT_PICKUP:
          strategy = SentOrdersBuildStrategy(this);
          break;
        case OrderStatus.AWAIT_DELIVERY:
          strategy = NormalOrdersBuildStrategy(this);
          break;
        case OrderStatus.AWAIT_RATING:
          strategy = NormalOrdersBuildStrategy(this);
          break;
        case OrderStatus.COMPLETED:
          strategy = NormalOrdersBuildStrategy(this);
          break;
        default:
          strategy = MixOrdersBuildStrategy(this);
          break;
      }
    } else {
      switch (orderType) {
        case OrderStatus.PENDING_CONFIRMATION:
          strategy = NormalOrdersBuildStrategy(this);
          break;
        case OrderStatus.AWAIT_PICKUP:
          strategy = CanCancelOrdersBuildStrategy(this);
          break;
        case OrderStatus.AWAIT_DELIVERY:
          strategy = ConfirmReceivedOrdersBuildStrategy(this);
          break;
        case OrderStatus.AWAIT_RATING:
          strategy = NormalOrdersBuildStrategy(this);
          break;
        case OrderStatus.COMPLETED:
          strategy = NormalOrdersBuildStrategy(this);
          break;
        default:
          strategy = MixOrdersBuildStrategy(this);
          break;
      }
    }
    return strategy;
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