import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/bills/bill_model.dart';
import 'package:pcplus/models/bills/bill_of_shop_model.dart';
import 'package:pcplus/models/bills/bill_of_shop_repo.dart';
import 'package:pcplus/models/bills/bill_repo.dart';
import 'package:pcplus/models/bills/bill_shop_item_model.dart';
import 'package:pcplus/models/bills/bill_shop_model.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_repo.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/pages/bill/bill_product/bill_product_contract.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/models/orders/order_address_model.dart';

import '../../../const/order_status.dart';
import '../../../models/in_cart_items/item_in_cart_with_seller.dart';
import '../../../models/system/param_store_repo.dart';
import '../../../services/notification_service.dart';

class BillProductPresenter {
  final BillProductContract _view;
  BillProductPresenter(this._view);

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

  Future<bool> performPayment() async {
    if (validateOnPaymentItem() == false) {
      return false;
    }

    BillRepository billRepository = BillRepository();
    BillOfShopRepository billOfShopRepository = BillOfShopRepository();
    UserRepository userRepository = UserRepository();
    ParamStoreRepository paramRepository = ParamStoreRepository();
    NotificationService notificationService = NotificationService();

    UserModel? user = await userRepository.getUserById(userId!);

    String? billID = await billRepository.generateID();

    if (billID == null || user == null) {
      return false;
    }

    DateTime orderDate = DateTime.now();

    BillModel newBill = BillModel(
        billID: billID,
        userID: userId,
        shops: [],
        orderDate: orderDate,
        shipInformation: user.shipInformationModel,
        paymentType: PaymentType.byCashOnDelivery,
        totalPrice: 0,
    );

    for (ItemInCartWithSeller data in onPaymentItems!) {
      String shopId = data.seller.shopID!;

      BillShopModel? billShop;

      for (BillShopModel shop in newBill.shops!) {
        if (shop.shopID == shopId) {
          billShop = shop;
        }
        break;
      }

      billShop ??= BillShopModel(
          shopID: shopId,
          shopName: data.seller.name,
          buyItems: [],
          status: OrderStatus.PENDING_CONFIRMATION,
          voucher: null,
        );

      BillShopItemModel newItem = BillShopItemModel(
          itemID: data.item.itemID,
          name: data.item.name,
          itemType: data.item.itemType,
          sellerID: shopId,
          addDate: orderDate,
          price: data.item.price,
          color: data.inCart.color,
          amount: data.inCart.amount,
          totalCost: data.item.price! * data.inCart.amount!,
      );

      billShop.buyItems!.add(newItem);
    }

    await billRepository.addBillToFirestore(userId!, newBill);

    for (BillShopModel shop in newBill.shops!) {
      BillOfShopModel? billOfShopModel = newBill.toBillOfShopModel(shop.shopID!);
      if (billOfShopModel == null) {
        return false;
      }
      // Tạo Bill trong shop
      await billOfShopRepository.addBillOfShopToFirestore(shop.shopID!, billOfShopModel);
      // Gửi thông báo tới shop
      await notificationService.createOrderingNotification(shop.shopID!, billOfShopModel);
    }
    // Xóa item trong giỏ hàng
    for (ItemInCartWithSeller data in onPaymentItems!) {
      await _inCartItemRepo.deleteItemInCart(userId!, data.inCart);
    }

    await paramRepository.increaseOrderIdIndex();

    return true;
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

    if (onPaymentItems == null) return "-";

    for (ItemInCartWithSeller data in onPaymentItems!) {
      total += data.inCart.amount! * data.item.price! + data.inCart.deliveryCost!;
    }

    return Utility.formatCurrency(total);
  }

  void handleBack() {
    _view.onBack();
  }


}