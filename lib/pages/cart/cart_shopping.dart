// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/component/item_argument.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/cart/cart_shopping_screen_contract.dart';
import 'package:pcplus/pages/cart/cart_shopping_screen_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product.dart';

import 'package:pcplus/models/in_cart_items/item_in_cart_with_seller.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_model.dart';
import '../bill/bill_product/bill_product.dart';
import '../widgets/bottom/bottom_bar_custom.dart';
import '../widgets/util_widgets.dart';
import '../widgets/listItem/cart_item.dart';

class CartShoppingScreen extends StatefulWidget {
  const CartShoppingScreen({super.key});
  static const String routeName = 'cart_shopping_screen';

  @override
  State<CartShoppingScreen> createState() => _CartShoppingScreenState();
}

class _CartShoppingScreenState extends State<CartShoppingScreen>
    implements CartShoppingScreenContract {
  // final CartSingleton _cartSingleton = CartSingleton.getInstance();
  CartShoppingScreenPresenter? _presenter;

  bool _selectAll = false;
  int soluong = 0;
  int checkedCount = 0;
  String totalPrice = "";

  @override
  void initState() {
    _presenter = CartShoppingScreenPresenter(this);
    super.initState();

    loadData();
  }

  @override
  void dispose() {
    _presenter?.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (mounted) {
      await _presenter?.getData();
    }
  }

  // ✅ Helper method để process cart data, tránh logic nặng trong StreamBuilder
  void _processCartData(List<ItemInCartWithSeller> itemsWithSeller) {
    _presenter!.inCartItems = itemsWithSeller;

    String remoteTotalPrice = _presenter!.calculateTotalPrice();
    int remoteAmount = itemsWithSeller.length;
    int remoteCheckedCount = _presenter!.getCheckedCount();

    // ✅ Chỉ update khi thực sự thay đổi
    if (soluong != remoteAmount ||
        totalPrice != remoteTotalPrice ||
        checkedCount != remoteCheckedCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            soluong = remoteAmount;
            totalPrice = remoteTotalPrice;
            checkedCount = remoteCheckedCount;
          });
        }
      });
    }
  }

  void _toggleSelectAll(bool? value) {
    _presenter?.handleSelectAll(value ?? false);
    if (mounted) {
      setState(() {
        _selectAll = value ?? false;
        totalPrice = _presenter!.calculateTotalPrice();
      });
    }
  }

  void _toggleItemChecked(InCartItemModel model, bool? value) {
    _presenter?.handleSelectItem(model, value ?? false);
  }

  void _deleteItem(InCartItemModel model) {
    _presenter?.handleDelete(model);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Gap(10),
            Text(
              'Giỏ hàng',
              style: TextDecor.robo24Medi.copyWith(
                color: Colors.black,
              ),
            ),
            const Gap(10),
            Text(
              '($soluong)',
              style: TextDecor.robo24Medi.copyWith(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                // _cartSingleton.inCartItems.isEmpty ?
                StreamBuilder<List<ItemInCartWithSeller>>(
                    stream: _presenter!.inCartItemsStream,
                    builder: (context, snapshot) {
                      Widget? result = UtilWidgets.createSnapshotResultWidget(
                          context, snapshot);
                      if (result != null) {
                        return result;
                      }

                      final itemsWithSeller = snapshot.data ?? [];

                      // ✅ FIX: Tách logic ra method riêng để tránh infinite rebuild
                      _processCartData(itemsWithSeller);

                      if (itemsWithSeller.isEmpty) {
                        return const Center(child: Text('Không có gì ở đây'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        // physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: itemsWithSeller.length,
                        itemBuilder: (context, index) {
                          ItemInCartWithSeller itemData =
                              itemsWithSeller[index];

                          return CartItem(
                            shopName: itemData.seller.name!,
                            itemName: itemData.item.name!,
                            description: itemData.item.description!,
                            rating: itemData.item.rating!,
                            location: itemData.seller.location!,
                            imageUrl: itemData.item.image!,
                            onChanged: (value) =>
                                _toggleItemChecked(itemData.inCart, value),
                            isCheck: itemData.inCart.isSelected!,
                            price: itemData.item.discountPrice!,
                            stock: itemData.item.stock!,
                            color: itemData.inCart.color!.name!,
                            amount: itemData.inCart.amount!,
                            onDelete: () => _deleteItem(itemData.inCart),
                            onPressed: () => _presenter?.handleItemPressed(
                                ItemWithSeller(
                                    item: itemData.item,
                                    seller: itemData.seller)),
                            onChangeAmount: (value) =>
                                _presenter?.handleChangeItemAmount(
                                    itemData.inCart, value),
                          );
                        },
                      );
                    }),
          ),
          Container(
            height: 60,
            width: size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _selectAll,
                  onChanged: _toggleSelectAll,
                ),
                Text(
                  'Chọn tất cả',
                  style: TextDecor.robo15Medi,
                ),
                Expanded(child: Container()),
                Text("Tổng: ", style: TextDecor.robo14),
                Text(totalPrice, style: TextDecor.robo17Medi),
                const Gap(8),
                InkWell(
                  onTap: () {
                    _presenter!.handleBuy();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 60,
                    width: 115,
                    decoration: const BoxDecoration(
                      color: Palette.primaryColor,
                    ),
                    child: Text(
                      'Mua hàng (${checkedCount.toString()})',
                      style: TextDecor.robo16Semi,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBarCustom(
        currentIndex: 1,
      ),
    );
  }

  @override
  void onBuy() {
    Navigator.of(context).pushNamed(BillProduct.routeName);
  }

  @override
  void onDeleteItem() {
    if (mounted) {
      setState(() {
        totalPrice = _presenter!.calculateTotalPrice();
      });
    }
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  @override
  void onSelectItem() {
    if (mounted) {
      setState(() {
        totalPrice = _presenter!.calculateTotalPrice();
        // _selectAll = _cartSingleton.inCartItems.every((element) => element.isCheck);
      });
    }
  }

  @override
  void onSelectAll() {
    if (mounted) {
      setState(() {
        totalPrice = _presenter!.calculateTotalPrice();
      });
    }
  }

  @override
  void onLoadDataSucceeded() {
    if (mounted) {
      setState(() {
        // totalPrice = _presenter!.calculateTotalPrice();
        // totalPrice = "0";
      });
    }
  }

  @override
  void onItemPressed(ItemWithSeller item) {
    Navigator.of(context).pushNamed(
      DetailProduct.routeName,
      arguments: ItemArgument(data: item),
    );
  }

  @override
  void onBuyFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onChangeItemAmount() {
    if (mounted) {
      setState(() {
        totalPrice = _presenter!.calculateTotalPrice();
      });
    }
  }
}
