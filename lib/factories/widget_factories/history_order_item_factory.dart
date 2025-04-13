import 'package:pcplus/commands/history_order_item/cancel_order_command.dart';
import 'package:pcplus/commands/history_order_item/received_order_command.dart';
import 'package:pcplus/commands/history_order_item/sent_order_command.dart';
import 'package:pcplus/commands/history_order_item/validate_order_command.dart';

import '../../models/orders/order_model.dart';
import '../../pages/history_order/history_order_presenter.dart';
import '../../pages/widgets/listItem/history_item.dart';

class FactoryOrderItemFactory {

  static HistoryItem createCanCancelOrderWidget(HistoryOrderPresenter? presenter, OrderModel order) {
    return HistoryItem(
      shopName: order.shopName!,
      isShop: presenter!.isShop,
      productName: order.itemModel!.name!,
      amount: order.amount!,
      receiverName: order.receiverName!,
      image: order.itemModel!.image!,
      price: order.itemModel!.price!,
      status: order.status!,
      address: order.address!.getFullAddress(),
      onCancelOrder: CancelOrderCommand(
        presenter: presenter,
        model: order,
      ),
    );
  }

  static HistoryItem createConfirmReceivedOrderWidget(HistoryOrderPresenter? presenter, OrderModel order) {
    return HistoryItem(
      shopName: order.shopName!,
      isShop: presenter!.isShop,
      productName: order.itemModel!.name!,
      receiverName: order.receiverName!,
      image: order.itemModel!.image!,
      amount: order.amount!,
      price: order.itemModel!.price!,
      status: order.status!,
      address: order.address!.getFullAddress(),
      onReceivedOrder: ReceivedOrderCommand(
        presenter: presenter,
        model: order,
      ),
      presenter: presenter,
      order: order,
    );
  }

  static HistoryItem createNeedConfirmOrderWidget(HistoryOrderPresenter? presenter, OrderModel order) {
    return HistoryItem(
      shopName: order.shopName!,
      isShop: presenter!.isShop,
      productName: order.itemModel!.name!,
      receiverName: order.receiverName!,
      image: order.itemModel!.image!,
      amount: order.amount!,
      price: order.itemModel!.price!,
      status: order.status!,
      address: order.address!.getFullAddress(),
      onValidateOrder: ValidateOrderCommand(
        presenter: presenter,
        model: order,
      ),
      onCancelOrder: CancelOrderCommand(
        presenter: presenter,
        model: order,
      ),
    );
  }

  static HistoryItem createNormalOrderWidget(HistoryOrderPresenter? presenter, OrderModel order) {
    return HistoryItem(
      shopName: order.shopName!,
      isShop: presenter!.isShop,
      productName: order.itemModel!.name!,
      receiverName: order.receiverName!,
      image: order.itemModel!.image!,
      amount: order.amount!,
      price: order.itemModel!.price!,
      status: order.status!,
      address: order.address!.getFullAddress(),
    );
  }

  static HistoryItem createSentOrderWidget(HistoryOrderPresenter? presenter, OrderModel order) {
    return HistoryItem(
      shopName: order.shopName!,
      isShop: presenter!.isShop,
      productName: order.itemModel!.name!,
      receiverName: order.receiverName!,
      image: order.itemModel!.image!,
      amount: order.amount!,
      price: order.itemModel!.price!,
      status: order.status!,
      address: order.address!.getFullAddress(),
      onSentOrder: SentOrderCommand(
        presenter: presenter,
        model: order,
      ),
      presenter: presenter,
      order: order,
    );
  }

}