import 'package:pcplus/interfaces/command.dart';

import '../../models/bills/bill_model.dart';
import '../../models/orders/order_model.dart';
import '../../pages/history_order/history_order_presenter.dart';

class ReceivedOrderCommand implements ICommand {
  HistoryOrderPresenter presenter;
  String shopID;
  BillModel model;

  ReceivedOrderCommand({
    required this.presenter,
    required this.shopID,
    required this.model,
  });

  @override
  void execute() {
    presenter.handleAlreadyReceivedOrder(model, shopID);
  }

}