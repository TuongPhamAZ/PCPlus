import 'package:pcplus/interfaces/command.dart';

import '../../models/orders/order_model.dart';
import '../../pages/history_order/history_order_presenter.dart';

class CancelOrderCommand implements ICommand {
  HistoryOrderPresenter presenter;
  OrderModel model;
  String? reason;

  CancelOrderCommand({
    required this.presenter,
    required this.model,
    this.reason,
  });

  @override
  void execute() {
    presenter.handleCancelOrder(model, reason ?? "");
  }

}