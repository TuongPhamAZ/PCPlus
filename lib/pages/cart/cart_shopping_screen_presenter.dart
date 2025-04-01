import 'package:pcplus/pages/cart/cart_shopping_screen_contract.dart';
import 'package:pcplus/objects/in_cart_item_data.dart';
import 'package:pcplus/singleton/cart_singleton.dart';
import 'package:pcplus/singleton/view_item_singleton.dart';

import '../../objects/suggest_item_data.dart';
import '../../services/utility.dart';

class CartShoppingScreenPresenter {
  final CartShoppingScreenContract _view;
  CartShoppingScreenPresenter(this._view);

  // final CartSingleton _cartSingleton = CartSingleton.getInstance();
  final ViewItemSingleton _itemSingleton = ViewItemSingleton.getInstance();

  Future<void> getData() async {
    // _cartSingleton.deselectAllItemsInCart();
    // _cartSingleton.resetAmount();
    // await _cartSingleton.fetchData();
    _view.onLoadDataSucceeded();
  }

  void handleDelete(int index) {
    // _cartSingleton.removeInCartItem(_cartSingleton.inCartItems[index]);
    _view.onDeleteItem();
  }

  Future<void> handleItemPressed(InCartItemData item) async {
    _view.onWaitingProgressBar();
    ItemData itemData = ItemData(
      product: item.item,
      shop: item.shop,
    );
    await itemData.loadRating();
    await _itemSingleton.storeItemData(itemData);
    _view.onPopContext();
    _view.onItemPressed();
  }

  void handleSelectItem(int index, bool check) {
    // _cartSingleton.inCartItems[index].isCheck = check;
    _view.onSelectItem();
  }

  void handleSelectAll(bool value) {
    // if (value) {
    //   _cartSingleton.selectAllItemsInCart();
    // } else {
    //   _cartSingleton.deselectAllItemsInCart();
    // }
  }

  void handleChangeItemAmount(int index, int value) {
    // _cartSingleton.inCartItems[index].amount = value;
    _view.onChangeItemAmount();
  }

  Future<void> handleBuy() async {
    if (getCheckedCount() == 0) {
      return;
    }
    _view.onWaitingProgressBar();
    // if (await _cartSingleton.validateIfSelectedItemsBuyable()) {
    //   await _cartSingleton.prepareForPayment();
    //   _view.onPopContext();
    //   _view.onBuy();
    // } else {
    //   _view.onPopContext();
    //   _view.onLoadDataSucceeded();
    //   _view.onBuyFailed("Có mặt hàng không thể mua được");
    // }
  }

  int getCheckedCount() {
    // return _cartSingleton.inCartItems.where((element) => element.isCheck).length;
    return 0;
  }

  String calculateTotalPrice() {
    int total = 0;
    // for (var element in _cartSingleton.inCartItems) {
    //   if (element.isCheck) {
    //     total += element.item!.price! * element.amount;
    //   }
    // }
    return Utility.formatCurrency(total);
  }
}