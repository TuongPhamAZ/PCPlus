import 'package:pcplus/commands/history_order_item/cancel_order_command.dart';
import 'package:pcplus/commands/history_order_item/received_order_command.dart';

import '../../models/bills/bill_model.dart';
import '../../models/bills/bill_shop_model.dart';
import '../../pages/history_order/history_order_presenter.dart';
import '../../pages/widgets/listItem/history_item.dart';

class OrderItemFactory {

  static HistoryItem? createCanCancelOrderWidget(
      HistoryOrderPresenter? presenter,
      BillModel bill,
      String shopID,
  ) {
    BillShopModel? billShopModel = bill.getBillShopModel(shopID);

    if (billShopModel == null) {
      return null;
    }

    return HistoryItem(
      shopName: billShopModel.shopName!,
      isShop: presenter!.isShop,
      products: billShopModel.buyItems!,
      receiverName: bill.shipInformation!.location!,
      image: billShopModel.buyItems!.first.image!,
      price: billShopModel.totalPrice!,
      status: billShopModel.status!,
      address: bill.shipInformation!.location!,
      onCancelOrder: CancelOrderCommand(
        presenter: presenter,
        model: bill,
        shopID: shopID,
      ),
    );
  }

  static HistoryItem? createConfirmReceivedOrderWidget(
      HistoryOrderPresenter? presenter,
      BillModel bill,
      String shopID,
  ) {
    BillShopModel? billShopModel = bill.getBillShopModel(shopID);

    if (billShopModel == null) {
      return null;
    }

    return HistoryItem(
      shopName: billShopModel.shopName!,
      isShop: presenter!.isShop,
      products: billShopModel.buyItems!,
      receiverName: bill.shipInformation!.location!,
      image: billShopModel.buyItems!.first.image!,
      price: billShopModel.totalPrice!,
      status: billShopModel.status!,
      address: bill.shipInformation!.location!,
      onReceivedOrder: ReceivedOrderCommand(
        presenter: presenter,
        model: bill,
        shopID: shopID,
      ),
    );
  }



  static HistoryItem? createNormalOrderWidget(
      HistoryOrderPresenter? presenter,
      BillModel bill,
      String shopID,
  ) {
    BillShopModel? billShopModel = bill.getBillShopModel(shopID);

    if (billShopModel == null) {
      return null;
    }

    return HistoryItem(
      shopName: billShopModel.shopName!,
      isShop: presenter!.isShop,
      products: billShopModel.buyItems!,
      receiverName: bill.shipInformation!.location!,
      image: billShopModel.buyItems!.first.image!,
      price: billShopModel.totalPrice!,
      status: billShopModel.status!,
      address: bill.shipInformation!.location!,
    );
  }


}