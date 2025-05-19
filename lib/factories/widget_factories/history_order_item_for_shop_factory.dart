import 'package:pcplus/commands/history_order_item/cancel_order_command.dart';
import 'package:pcplus/commands/history_order_item/sent_order_command.dart';
import 'package:pcplus/commands/history_order_item/validate_order_command.dart';
import '../../models/bills/bill_of_shop_model.dart';
import '../../pages/history_order/history_order_presenter.dart';
import '../../pages/widgets/listItem/history_item.dart';

class OrderItemForShopFactory {

  static HistoryItem? createNeedConfirmOrderWidget(
      HistoryOrderPresenter? presenter,
      BillOfShopModel bill,
      String shopName,
  ) {
    return HistoryItem(
      shopName: shopName,
      isShop: presenter!.isShop,
      products: bill.items!,
      receiverName: bill.shipInformation!.location!,
      image: bill.items!.first.image!,
      price: bill.totalPrice!,
      status: bill.status!,
      address: bill.shipInformation!.location!,
      onValidateOrder: ValidateOrderCommand(
        presenter: presenter,
        model: bill,
      ),
      onCancelOrder: CancelOrderForShopCommand(
        presenter: presenter,
        billOfShopModel: bill,
      ),
    );
  }

  static HistoryItem? createNormalOrderWidget(
      HistoryOrderPresenter? presenter,
      BillOfShopModel bill,
      String shopName,
  ) {
    return HistoryItem(
      shopName: shopName,
      isShop: presenter!.isShop,
      products: bill.items!,
      receiverName: bill.shipInformation!.location!,
      image: bill.items!.first.image!,
      price: bill.totalPrice!,
      status: bill.status!,
      address: bill.shipInformation!.location!,
    );
  }

  static HistoryItem? createSentOrderWidget(
      HistoryOrderPresenter? presenter,
      BillOfShopModel bill,
      String shopName,
  ) {
    return HistoryItem(
      shopName: shopName,
      isShop: presenter!.isShop,
      products: bill.items!,
      receiverName: bill.shipInformation!.location!,
      image: bill.items!.first.image!,
      price: bill.totalPrice!,
      status: bill.status!,
      address: bill.shipInformation!.location!,
      onSentOrder: SentOrderCommand(
        presenter: presenter,
        model: bill,
      ),
    );
  }

}