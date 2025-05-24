import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/bills/bill_model.dart';
import 'package:pcplus/models/bills/bill_of_shop_model.dart';
import 'package:pcplus/models/bills/bill_of_shop_repo.dart';
import 'package:pcplus/models/bills/bill_repo.dart';
import 'package:pcplus/models/bills/bill_shop_item_model.dart';
import 'package:pcplus/models/bills/bill_shop_model.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_repo.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/pages/bill/bill_product/bill_product_contract.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/services/utility.dart';

import '../../../models/in_cart_items/item_in_cart_with_seller.dart';
import '../../../models/system/param_store_repo.dart';
import '../../../models/users/ship_infor_model.dart';
import '../../../services/notification_service.dart';

class BillProductPresenter {
  final BillProductContract _view;
  BillProductPresenter(this._view) {
    // _momoPay = MomoVn();
    // _momoPay.on(MomoVn.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _momoPay.on(MomoVn.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _paymentStatus = "";
  }

  // late MomoVn _momoPay;
  // late PaymentResponse _momoPaymentResult;
  // late String _paymentStatus;

  final InCartItemRepo _inCartItemRepo = InCartItemRepo();
  final ItemRepository _itemRepo = ItemRepository();
  final UserRepository _userRepo = UserRepository();

  ShipInformationModel? address;
  String? userId;

  Stream<List<ItemInCartWithSeller>>? inCartItemsStream;
  List<ItemInCartWithSeller>? onPaymentItems;
  Map<String, BillShopModel>? billShops;

  Future<void> getData() async {
    if (inCartItemsStream != null) {
      return;
    }

    billShops = {};

    userId = SessionController.getInstance().userID;
    UserModel? user = await _userRepo.getUserById(userId!);
    if (user != null) {
      address = user.shipInformationModel;
    } else {
      address = ShipInformationModel(
        receiverName: "",
        location: "",
        phone: "",
        isDefault: true,
      );
    }

    inCartItemsStream = _inCartItemRepo.getAllItemsInCartStream(userId!);
    _view.onLoadDataSucceeded();
  }

  Future<void> handleChangeDelivery({
    required BillShopModel data,
    required String deliveryMethod,
    required int cost,
  }) async {
    data.deliveryMethod = deliveryMethod;
    data.deliveryCost = cost;
    _view.onChangeDelivery();
  }

  Future<void> handleNoteForShop(
      {required BillShopModel data, required String text}) async {
    data.noteForShop = text;
  }

  void handleChangeLocation(ShipInformationModel address) {
    PrefService.saveLocationData(addressData: address);
  }

  Future<void> handleOrder(ShipInformationModel address) async {
    if (address.isValid() == false) {
      _view.onBuyFailed("Vui lòng chọn địa chỉ giao hàng");
      return;
    }

    _view.onWaitingProgressBar();

    bool canBuy = validateOnPaymentItem();

    if (canBuy) {
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
      shops: billShops!.values.toList(),
      orderDate: orderDate,
      shipInformation: user.shipInformationModel,
      paymentType: PaymentType.byCashOnDelivery,
      totalPrice: 0,
    );

    for (ItemInCartWithSeller data in onPaymentItems!) {
      await SessionController.getInstance().onBuyProduct(data.item.itemID!, data.inCart.amount!);

      // update Item Data
      data.item.sold = data.item.sold! + data.inCart.amount!;
      data.item.stock = data.item.stock! - data.inCart.amount!;

      await _itemRepo.updateItem(data.item);
    }

    // Không cần tính tiền. Tổng tiền đã được tính trong hàm ToJson của BillModel
    await billRepository.addBillToFirestore(userId!, newBill);

    for (BillShopModel shop in newBill.shops!) {
      BillOfShopModel? billOfShopModel =
          newBill.toBillOfShopModel(shop.shopID!);
      if (billOfShopModel == null) {
        return false;
      }
      // Tạo Bill trong shop
      await billOfShopRepository.addBillOfShopToFirestore(
          shop.shopID!, billOfShopModel);
      // Gửi thông báo tới shop
      await notificationService.createOrderingNotification(
          shop.shopID!, billOfShopModel);
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

    if (billShops == null) {
      return "-";
    }

    for (BillShopModel data in billShops!.values) {
      for (BillShopItemModel item in data.buyItems ?? []) {
        total += item.amount! * item.price!;
      }
    }

    return Utility.formatCurrency(total);
  }

  String getShippingFee() {
    int total = 0;

    if (billShops == null) {
      return "-";
    }

    for (BillShopModel data in billShops!.values) {
      total += data.deliveryCost ?? 0;
    }

    return Utility.formatCurrency(total);
  }

  String getTotalCost() {
    int total = 0;

    if (billShops == null) return "-";

    for (BillShopModel data in billShops!.values) {
      total += data.deliveryCost ?? 0;
      for (BillShopItemModel item in data.buyItems ?? []) {
        total += item.amount! * item.price!;
      }
    }

    return Utility.formatCurrency(total);
  }

  void handleBack() {
    _view.onBack();
  }

  // TODO: MOMO HANDLER

  // void _createMomoPaymentRequest() {
  //   MomoPaymentInfo options = MomoPaymentInfo(
  //       merchantName: "TTN",
  //       appScheme: "MOxx",
  //       merchantCode: 'MOxx',
  //       partnerCode: 'Mxx',
  //       amount: 60000,
  //       orderId: '12321312',
  //       orderLabel: 'Gói combo',
  //       merchantNameLabel: "HLGD",
  //       fee: 10,
  //       description: 'Thanh toán combo',
  //       username: '01234567890',
  //       partner: 'merchant',
  //       extra: "{\"key1\":\"value1\",\"key2\":\"value2\"}",
  //       isTestMode: true
  //   );
  //   try {
  //     _momoPay.open(options);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  // void _handlePaymentSuccess(PaymentResponse response) {
  //   _momoPaymentResult = response;

  // }

  // void _handlePaymentError(PaymentResponse response) {
  //   _momoPaymentResult = response;
  // }
}
