import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_model.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_repo.dart';
import 'package:pcplus/models/in_cart_items/item_in_cart_with_seller.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/cart/cart_shopping_screen_contract.dart';
import '../../services/utility.dart';

class CartShoppingScreenPresenter {
  final CartShoppingScreenContract _view;
  CartShoppingScreenPresenter(this._view);

  final InCartItemRepo _inCartItemRepo = InCartItemRepo();

  final SessionController _sessionController = SessionController.getInstance();
  Stream<List<ItemInCartWithSeller>>? inCartItemsStream;
  List<ItemInCartWithSeller>? inCartItems;

  bool initCart = false;

  Future<void> getData() async {
    String userId = _sessionController.userID!;
    inCartItemsStream = _inCartItemRepo.getAllItemsInCartStream(userId);
    _view.onLoadDataSucceeded();
  }

  Future<void> handleDelete(InCartItemModel model) async {
    _view.onWaitingProgressBar();
    await _inCartItemRepo.deleteItemInCart(_sessionController.userID!, model);
    _view.onPopContext();
    _view.onDeleteItem();
  }

  Future<void> handleItemPressed(ItemWithSeller data) async {
    _view.onItemPressed(data);
  }

  Future<void> handleSelectItem(InCartItemModel model, bool check) async {
    // _cartSingleton.inCartItems[index].isCheck = check;
    // _view.onWaitingProgressBar();
    model.isSelected = check;
    await _inCartItemRepo.updateItemInCart(_sessionController.userID!, model);
    // _view.onPopContext();
    _view.onSelectItem();
  }

  Future<void> handleSelectAll(bool value) async {
    // _view.onWaitingProgressBar();
    await _inCartItemRepo.selectAllItemInCart(_sessionController.userID!, value);
    _view.onSelectAll();
    // _view.onPopContext();
  }

  Future<void> handleChangeItemAmount(InCartItemModel model, int value) async {
    // _view.onWaitingProgressBar();
    model.amount = value;
    await _inCartItemRepo.updateItemInCart(_sessionController.userID!, model);
    _view.onChangeItemAmount();
  }

  Future<void> handleBuy() async {
    if (getCheckedCount() == 0) {
      return;
    }
    _view.onWaitingProgressBar();

    // Check if all items are buyable

    for (ItemInCartWithSeller item in inCartItems!) {
      if (item.item.stock! < item.inCart.amount!) {
        _view.onPopContext();
        _view.onBuyFailed("Có mặt hàng không thể mua được");
        return;
      }
    }

    _view.onPopContext();
    _view.onBuy();
  }

  int getCheckedCount() {
    if (inCartItems == null) {
      return 0;
    }

    int count = 0;
    for (ItemInCartWithSeller item in inCartItems!) {
      if (item.inCart.isSelected!) {
        count ++;
      }
    }
    return count;
  }

  String calculateTotalPrice() {
    if (inCartItems == null) {
      return "-";
    }

    int total = 0;
    for (ItemInCartWithSeller item in inCartItems!) {
      if (item.inCart.isSelected!) {
        total += item.item.discountPrice! * item.inCart.amount!;
      }
    }
    return Utility.formatCurrency(total);
  }
}