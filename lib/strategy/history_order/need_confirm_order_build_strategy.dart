import 'package:flutter/cupertino.dart';
import 'package:pcplus/strategy/history_order/history_order_strategy.dart';

import '../../models/orders/order_model.dart';
import '../../pages/widgets/listItem/history_item.dart';

class NeedConfirmOrdersBuildStrategy extends HistoryOrderBuildListStrategy {

  NeedConfirmOrdersBuildStrategy(presenter) {
    this.presenter = presenter;
  }

  @override
  List<Widget> execute() {
    List<Widget> widgets = [];
    for (OrderModel order in presenter!.orders) {
      HistoryItem widget = createNeedConfirmOrderWidget(order);
      widgets.add(widget);
    }
    return widgets;
  }

}