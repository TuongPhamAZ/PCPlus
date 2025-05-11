import 'package:pcplus/interfaces/command.dart';
import '../../models/bills/bill_of_shop_model.dart';
import '../../pages/history_order/history_order_presenter.dart';

class SentOrderCommand implements ICommand {
  HistoryOrderPresenter presenter;
  BillOfShopModel model;

  SentOrderCommand({
    required this.presenter,
    required this.model,
  });

  @override
  void execute() {
    presenter.handleSentOrderForShop(model);
  }

}