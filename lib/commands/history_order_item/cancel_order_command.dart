import 'package:pcplus/interfaces/command.dart';

import '../../models/bills/bill_model.dart';
import '../../models/bills/bill_of_shop_model.dart';
import '../../pages/history_order/history_order_presenter.dart';

class CancelOrderCommand implements ICommand {
  HistoryOrderPresenter presenter;
  BillModel? model;
  String shopID;
  String? reason;

  CancelOrderCommand({
    required this.presenter,
    required this.shopID,
    required this.model,
    this.reason,
  });

  @override
  void execute() {
    presenter.handleCancelOrder(model!, shopID, reason ?? "");
  }
}

class CancelOrderForShopCommand extends CancelOrderCommand {
  BillOfShopModel billOfShopModel;

  CancelOrderForShopCommand({
    required super.presenter,
    required this.billOfShopModel,
  }) : super(shopID: '', model: null);

  @override
  void execute() {
    presenter.handleCancelOrderForShop(billOfShopModel, reason ?? "");
  }
}