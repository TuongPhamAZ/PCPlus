import 'package:pcplus/contract/bill_product_contract.dart';
import 'package:pcplus/objects/in_cart_item_data.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/singleton/cart_singleton.dart';
import 'package:pcplus/models/orders/order_address_model.dart';

class BillProductPresenter {
  final BillProductContract _view;
  BillProductPresenter(this._view);

  final CartSingleton _cartSingleton = CartSingleton.getInstance();
  final PrefService _pref = PrefService();

  Future<void> handleChangeDelivery({
    required InCartItemData data,
    required String deliveryMethod,
    required int cost,
  }) async {
    data.deliveryMethod = deliveryMethod;
    data.deliveryCost = cost;
    await Future.delayed(const Duration(milliseconds: 500));
    _view.onChangeData();
  }

  void handleNoteForShop({
    required InCartItemData data,
    required String text
  }) {
    data.noteForShop = text;
  }

  void handleChangeLocation(OrderAddressModel address) {
    _cartSingleton.address = address;
    _pref.saveLocationData(addressData: address);
  }

  Future<void> handleOrder(OrderAddressModel address) async {
    if (address.isValid() == false) {
      _view.onBuyFailed("Vui lòng chọn địa chỉ giao hàng");
      return;
    }

    _view.onWaitingProgressBar();

    if (await _cartSingleton.validateOnPaymentItemsBuyable()){
      // Create Order
      _cartSingleton.address = address;
      await _cartSingleton.performPayment();
      _view.onPopContext();
      _view.onBuy();
    } else {
      _view.onPopContext();
      _view.onBuyFailed("Có mặt hàng không thể mua được");
    }
  }

  String getProductCost() {
    int total = 0;
    for (InCartItemData data in _cartSingleton.onPaymentItems) {
      total += data.amount * data.item!.price!;
    }
    return Utility.formatCurrency(total);
  }

  String getShippingFee() {
    int total = 0;
    for (InCartItemData data in _cartSingleton.onPaymentItems) {
      total += data.deliveryCost;
    }
    return Utility.formatCurrency(total);
  }

  String getTotalCost() {
    int total = 0;
    for (InCartItemData data in _cartSingleton.onPaymentItems) {
      total += data.amount * data.item!.price! + data.deliveryCost;
    }
    return Utility.formatCurrency(total);
  }

  void handleBack() {
    _cartSingleton.clearOnPaymentItems();
    _view.onBack();
  }


}