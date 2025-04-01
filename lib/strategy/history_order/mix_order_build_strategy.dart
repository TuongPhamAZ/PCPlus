import 'package:flutter/cupertino.dart';
import 'package:pcplus/strategy/history_order/history_order_strategy.dart';

import '../../const/order_status.dart';
import '../../models/orders/order_model.dart';
import '../../pages/widgets/listItem/history_item.dart';

class MixOrdersBuildStrategy extends HistoryOrderBuildListStrategy {

  MixOrdersBuildStrategy(presenter) {
    this.presenter = presenter;
  }

  @override
  List<Widget> execute() {
    List<Widget> widgets = [];
    for (OrderModel order in presenter!.orders) {
      HistoryItem? widget;
      if (presenter!.isShop) {
        switch (order.status) {
          case OrderStatus.PENDING_CONFIRMATION:
            widget = createNeedConfirmOrderWidget(order);
            break;
          case OrderStatus.AWAIT_PICKUP:
            widget = createSentOrderWidget(order);
            break;
          case OrderStatus.AWAIT_DELIVERY:
            widget = createNormalOrderWidget(order);
            break;
          case OrderStatus.AWAIT_RATING:
            widget = createNormalOrderWidget(order);
            break;
          case OrderStatus.COMPLETED:
            widget = createNormalOrderWidget(order);
            break;
        }
      } else {
        switch (order.status) {
          case OrderStatus.PENDING_CONFIRMATION:
            widget = createNormalOrderWidget(order);
            break;
          case OrderStatus.AWAIT_PICKUP:
            widget = createCanCancelOrderWidget(order);
            break;
          case OrderStatus.AWAIT_DELIVERY:
            widget = createConfirmReceivedOrderWidget(order);
            break;
          case OrderStatus.AWAIT_RATING:
            widget = createNormalOrderWidget(order);
            break;
          case OrderStatus.COMPLETED:
            widget = createNormalOrderWidget(order);
            break;
        }
      }
      widget ??= createNormalOrderWidget(order);
      widgets.add(widget);
    }
    return widgets;
  }

}