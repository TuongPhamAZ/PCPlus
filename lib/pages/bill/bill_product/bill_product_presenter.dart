import 'package:flutter/cupertino.dart';
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
import 'package:pcplus/models/vouchers/voucher_repo.dart';
import 'package:pcplus/pages/bill/bill_product/bill_product_contract.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/services/zalo_pay_service.dart';
import 'dart:async';

import '../../../models/in_cart_items/item_in_cart_with_seller.dart';
import '../../../models/system/param_store_repo.dart';
import '../../../models/users/ship_infor_model.dart';
import '../../../models/vouchers/voucher_model.dart';
import '../../../services/notification_service.dart';

class BillProductPresenter {
  final BillProductContract _view;
  BillProductPresenter(this._view);

  final ZaloPayService _zaloPayService = ZaloPayService();

  final InCartItemRepo _inCartItemRepo = InCartItemRepo();
  final ItemRepository _itemRepo = ItemRepository();
  final UserRepository _userRepo = UserRepository();

  final BillRepository _billRepository = BillRepository();
  final BillOfShopRepository _billOfShopRepository = BillOfShopRepository();
  final ParamStoreRepository _paramRepository = ParamStoreRepository();
  final NotificationService _notificationService = NotificationService();

  ShipInformationModel? address;
  String? userId;
  String paymentMethod = 'Cash on delivery'; // Thêm payment method

  // StreamController để quản lý lifecycle
  StreamController<List<ItemInCartWithSeller>>? _inCartItemsController;
  StreamSubscription<List<ItemInCartWithSeller>>? _inCartItemsSubscription;

  // Getter cho stream
  Stream<List<ItemInCartWithSeller>>? get inCartItemsStream =>
      _inCartItemsController?.stream;

  List<ItemInCartWithSeller>? onPaymentItems;
  Map<String, BillShopModel>? billShops;
  Map<String, VoucherModel?>? cacheVouchers;

  bool _isDisposed = false;

  Future<void> getData() async {
    if (_isDisposed) return;

    if (inCartItemsStream != null) {
      return;
    }

    billShops = {};
    cacheVouchers = {};

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

    // Khởi tạo controller nếu chưa có
    _inCartItemsController ??= StreamController<List<ItemInCartWithSeller>>();

    // Lắng nghe stream từ repository
    _inCartItemsSubscription =
        _inCartItemRepo.getAllItemsInCartStream(userId!).listen(
      (data) {
        if (!_isDisposed && !_inCartItemsController!.isClosed) {
          _inCartItemsController!.add(data);
        }
      },
      onError: (error) {
        if (!_isDisposed && !_inCartItemsController!.isClosed) {
          _inCartItemsController!.addError(error);
        }
      },
    );

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

  Future<void> handleChangeVoucher(
      {required BillShopModel data, required VoucherModel? voucher}) async {
    data.voucher = voucher;
    cacheVouchers![data.shopID!] = voucher;
    _view.onChangeVoucher();
  }

  Future<void> handleNoteForShop(
      {required BillShopModel data, required String text}) async {
    data.noteForShop = text;
  }

  Future<void> handleChangeLocation(ShipInformationModel address) async {
    PrefService.saveLocationData(addressData: address);
    UserModel? user = SessionController.getInstance().currentUser;
    user!.shipInformationModel = address;

    await _userRepo.updateUser(user);
  }

  // Thêm method xử lý thay đổi payment method
  void handlePaymentMethodChanged(String newPaymentMethod) {
    paymentMethod = newPaymentMethod;
    _view.onPaymentMethodChanged();
  }

  Future<void> handleOrder(ShipInformationModel address) async {
    if (address.isValid() == false) {
      _view.onBuyFailed("Vui lòng chọn địa chỉ giao hàng");
      return;
    }

    // Kiểm tra payment method và hiển thị dialog tương ứng
    if (paymentMethod == 'Pay with ZaloPay') {
      _view.onShowPaymentWaitingDialog();
    } else {
      _view.onWaitingForPayment();
    }

    bool canBuy = validateOnPaymentItem();

    if (canBuy) {
      // Create Order
      await performPayment();
    } else {
      _view.onPopContext();
      _view.onBuyFailed("Có mặt hàng không thể mua được");
    }
  }

  Future<void> performPayment() async {
    if (validateOnPaymentItem() == false) {
      _view.onPopContext();
      _view.onBuyFailed("Đã có lỗi xảy ra. Hãy thử lại sau");
      return;
    }

    UserModel? user = await _userRepo.getUserById(userId!);

    String? billID = await _billRepository.generateID();

    if (billID == null || user == null) {
      _view.onPopContext();
      _view.onBuyFailed("Đã có lỗi xảy ra. Hãy thử lại sau");
      return;
    }

    DateTime orderDate = DateTime.now();

    String paymentTypeString = paymentMethod == 'Pay with ZaloPay'
        ? PaymentType.byZaloPay
        : PaymentType.byCashOnDelivery;

    BillModel newBill = BillModel(
      billID: billID,
      userID: userId,
      shops: billShops!.values.toList(),
      orderDate: orderDate,
      shipInformation: user.shipInformationModel,
      paymentType: paymentTypeString,
      totalPrice: 0,
    );

    // Tính tiền
    newBill.toJson();

    if (paymentMethod == 'Pay with ZaloPay') {
      await _handleZaloPayRequest(newBill.totalPrice!, newBill);
    } else {
      // Cash on delivery - xử lý trực tiếp
      await _processDataAfterPayment(newBill);
      _view.onPopContext();
      _view.onBuy();
    }
  }

  Future<void> _processDataAfterPayment(BillModel newBill) async {
    for (ItemInCartWithSeller data in onPaymentItems!) {
      await SessionController.getInstance()
          .onBuyProduct(data.item.itemID!, data.inCart.amount!);

      // update Item Data
      data.item.sold = data.item.sold! + data.inCart.amount!;
      data.item.stock = data.item.stock! - data.inCart.amount!;

      await _itemRepo.updateItem(data.item);
    }

    await _billRepository.addBillToFirestore(userId!, newBill);

    for (BillShopModel shop in newBill.shops!) {
      BillOfShopModel? billOfShopModel =
          newBill.toBillOfShopModel(shop.shopID!);
      if (billOfShopModel == null) {
        debugPrint(
            "Line 159 (bill_product_presenter): billOfShopModel == null!");
        return;
      }
      // Tạo Bill trong shop
      await _billOfShopRepository.addBillOfShopToFirestore(
          shop.shopID!, billOfShopModel);
      // Gửi thông báo tới shop
      await _notificationService.createOrderingNotification(
          shop.shopID!, billOfShopModel);
      // Cập nhật lại voucher
      if (billOfShopModel.voucher != null) {
        billOfShopModel.voucher!.quantity =
            billOfShopModel.voucher!.quantity! - 1;
        await VoucherRepository()
            .updateVoucher(shop.shopID!, billOfShopModel.voucher!);
      }
    }
    // Xóa item trong giỏ hàng
    for (ItemInCartWithSeller data in onPaymentItems!) {
      await _inCartItemRepo.deleteItemInCart(userId!, data.inCart);
    }

    await _paramRepository.increaseOrderIdIndex();
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

  String getVoucherReduce() {
    int total = 0;

    if (billShops == null) return "-";

    for (BillShopModel data in billShops!.values) {
      if (data.voucher != null) {
        total -= data.voucher!.discount!;
      }
    }

    return Utility.formatCurrency(total);
  }

  String getTotalCost() {
    int total = 0;

    if (billShops == null) return "-";

    for (BillShopModel data in billShops!.values) {
      total += data.deliveryCost ?? 0;
      if (data.voucher != null) {
        total -= data.voucher!.discount!;
      }
      for (BillShopItemModel item in data.buyItems ?? []) {
        total += item.amount! * item.price!;
      }
    }

    return Utility.formatCurrency(total);
  }

  void handleBack() {
    _view.onBack();
  }

  // Thêm method để xử lý đổi phương thức thanh toán từ dialog
  void handleChangePaymentMethodFromDialog() {
    _view.onPopContext(); // Đóng dialog
  }

  // TODO: ZALOPAY HANDLER

  Future<void> _handleZaloPayRequest(int amount, BillModel newBill) async {
    try {
      // Tạo order
      ZaloResult zaloResult = ZaloResult();
      var orderResult =
          await _zaloPayService.createZaloPayOrder(amount, zaloResult);

      if (orderResult != null && orderResult.zptranstoken.isNotEmpty) {
        // Thực hiện payment
        ZaloStatus? zaloStatus =
            await _zaloPayService.handleZaloPayOrder(orderResult, amount);

        if (zaloStatus != null) {
          await _processDataAfterPayment(newBill);
          _view.onPopContext();
          await Future.delayed(const Duration(milliseconds: 100));
          _view.onShowResultDialog(
              zaloStatus.title, zaloStatus.message, zaloStatus.isSuccess);
        } else {
          _view.onPopContext();
          _view.onShowResultDialog(
              "Lỗi", "Không thể tạo đơn hàng. Vui lòng thử lại", false);
        }
      } else {
        _view.onPopContext();
        _view.onShowResultDialog(
            "Lỗi", "Không thể tạo đơn hàng. Vui lòng thử lại", false);
      }
    } catch (e) {
      _view.onPopContext();
      _view.onShowResultDialog("Lỗi", "Có lỗi xảy ra: $e", false);
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _disposeStreams();
  }

  Future<void> _disposeStreams() async {
    await _inCartItemsSubscription?.cancel();
    _inCartItemsSubscription = null;

    if (_inCartItemsController != null && !_inCartItemsController!.isClosed) {
      await _inCartItemsController!.close();
    }
    _inCartItemsController = null;
  }
}
