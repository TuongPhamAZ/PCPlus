import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_repo.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/pages/bill/bill_product/bill_product_contract.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/models/orders/order_address_model.dart';

import '../../../const/order_status.dart';
import '../../../models/in_cart_items/item_in_cart_with_seller.dart';
import '../../../models/orders/order_model.dart';
import '../../../models/orders/order_repo.dart';
import '../../../models/system/param_store_repo.dart';
import '../../../services/notification_service.dart';

class BillProductPresenter {
  final BillProductContract _view;
  BillProductPresenter(this._view);

  // final CartSingleton _cartSingleton = CartSingleton.getInstance();
  final InCartItemRepo _inCartItemRepo = InCartItemRepo();

  OrderAddressModel? address;
  String? userId;

  Stream<List<ItemInCartWithSeller>>? inCartItemsStream;
  List<ItemInCartWithSeller>? onPaymentItems;

  Future<void> getData() async {
    address = await PrefService.loadLocationData();
    userId = SessionController.getInstance().userID;

    inCartItemsStream = _inCartItemRepo.getAllItemsInCartStream(userId!);
    _view.onLoadDataSucceeded();
  }

  Future<void> handleChangeDelivery({
    required ItemInCartWithSeller data,
    required String deliveryMethod,
    required int cost,
  }) async {
    data.inCart.deliveryMethod = deliveryMethod;
    data.inCart.deliveryCost = cost;
    await _inCartItemRepo.updateItemInCart(userId!, data.inCart);
    _view.onChangeData();
  }

  Future<void> handleNoteForShop({
    required ItemInCartWithSeller data,
    required String text
  }) async {
    data.inCart.noteForShop = text;
    await _inCartItemRepo.updateItemInCart(userId!, data.inCart);
  }

  void handleChangeLocation(OrderAddressModel address) {
    // _cartSingleton.address = address;
    PrefService.saveLocationData(addressData: address);
  }

  Future<void> handleOrder(OrderAddressModel address) async {
    if (address.isValid() == false) {
      _view.onBuyFailed("Vui lòng chọn địa chỉ giao hàng");
      return;
    }

    _view.onWaitingProgressBar();

    bool canBuy = validateOnPaymentItem();

    if (canBuy){
      // Create Order
      await performPayment();
      _view.onPopContext();
      _view.onBuy();
    } else {
      _view.onPopContext();
      _view.onBuyFailed("Có mặt hàng không thể mua được");
    }
  }

  Future<void> performPayment() async {
    if (validateOnPaymentItem() == false) {
      return;
    }

    OrderRepository orderRepository = OrderRepository();
    ParamStoreRepository paramRepository = ParamStoreRepository();
    NotificationService notificationService = NotificationService();

    UserModel? user = await PrefService.loadUserData();

    for (ItemInCartWithSeller data in onPaymentItems!) {
      String shopId = data.seller.shopID!;

      OrderModel newOrder = OrderModel(
          orderID: await orderRepository.generateID(),
          shopName: data.seller.name,
          receiverID: userId,
          orderDate: DateTime.now(),
          receiverName: user!.name,
          status: OrderStatus.PENDING_CONFIRMATION,
          address: address,
          itemModel: data.item.toOrderItemModel(color: data.inCart.color!),
          deliveryMethod: data.inCart.deliveryMethod,
          deliveryCost: data.inCart.deliveryCost,
          amount: data.inCart.amount,
      );

      orderRepository.addOrderToFirestore(userId!, newOrder);
      orderRepository.addOrderToFirestore(shopId, newOrder);
      await notificationService.createOrderingNotification(newOrder);

      await paramRepository.increaseOrderIdIndex();
      await _inCartItemRepo.deleteItemInCart(userId!, data.inCart);
    }
  }

  bool validateOnPaymentItem() {
    if (onPaymentItems == null) return false;

    for (ItemInCartWithSeller data in onPaymentItems!) {
      if (data.item.stock! < data.inCart.amount!) {
        return false;
      }
    }

    return true;
  }

  String getProductCost() {
    int total = 0;
    // for (InCartItemData data in _cartSingleton.onPaymentItems) {
    //   total += data.amount * data.item!.price!;
    // }
    if (onPaymentItems == null) {
      return "-";
    }

    for (ItemInCartWithSeller data in onPaymentItems!) {
      total += data.inCart.amount! * data.item.price!;
    }

    return Utility.formatCurrency(total);
  }

  String getShippingFee() {
    int total = 0;
    // for (InCartItemData data in _cartSingleton.onPaymentItems) {
    //   total += data.deliveryCost;
    // }
    if (onPaymentItems == null) {
      return "-";
    }

    for (ItemInCartWithSeller data in onPaymentItems!) {
      total += data.inCart.deliveryCost!;
    }

    return Utility.formatCurrency(total);
  }

  String getTotalCost() {
    int total = 0;
    // for (InCartItemData data in _cartSingleton.onPaymentItems) {
    //   total += data.amount * data.item!.price! + data.deliveryCost;
    // }
    if (onPaymentItems == null) return "-";

    for (ItemInCartWithSeller data in onPaymentItems!) {
      total += data.inCart.amount! * data.item.price! + data.inCart.deliveryCost!;
    }

    return Utility.formatCurrency(total);
  }

  void handleBack() {
    // _cartSingleton.clearOnPaymentItems();
    _view.onBack();
  }


}