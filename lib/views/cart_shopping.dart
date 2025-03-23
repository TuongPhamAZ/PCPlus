import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/contract/cart_shopping_screen_contract.dart';
import 'package:pcplus/objects/in_cart_item_data.dart';
import 'package:pcplus/presenter/cart_shopping_screen_presenter.dart';
import 'package:pcplus/singleton/cart_singleton.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/views/product/detail_product.dart';
import 'package:pcplus/views/widgets/bottom/bottom_bar_custom.dart';
import 'package:pcplus/views/widgets/listItem/cart_item.dart';
import 'package:pcplus/views/widgets/util_widgets.dart';

import 'bill/bill_product.dart';

class CartShoppingScreen extends StatefulWidget {
  const CartShoppingScreen({super.key});
  static const String routeName = 'cart_shopping_screen';

  @override
  State<CartShoppingScreen> createState() => _CartShoppingScreenState();
}

class _CartShoppingScreenState extends State<CartShoppingScreen> implements CartShoppingScreenContract {
  final CartSingleton _cartSingleton = CartSingleton.getInstance();
  CartShoppingScreenPresenter? _presenter;

  bool _selectAll = false;
  int soluong = 10;
  String totalPrice = "";

  @override
  void initState() {
    _presenter = CartShoppingScreenPresenter(this);
    soluong = _cartSingleton.inCartItems.length;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    await _presenter?.getData();
  }

  void _toggleSelectAll(bool? value) {
    _presenter?.handleSelectAll(value ?? false);
    setState(() {
      _selectAll = value ?? false;
      totalPrice = _presenter!.calculateTotalPrice();
    });
  }

  void _toggleItemChecked(int index, bool? value) {
    _presenter?.handleSelectItem(index, value ?? false);
  }

  void _deleteItem(int index) {
    _presenter?.handleDelete(index);
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
              'Cart Shopping',
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
              _cartSingleton.inCartItems.isEmpty ?
                UtilWidgets.getCenterTextWithContainer(
                  width: size.width,
                  height: size.height * 0.7,
                  text: "Nothing here",
                  color: Palette.primaryColor,
                  fontSize: 16
                )
                :
                ListView.builder(
                  itemCount: _cartSingleton.inCartItems.length,
                  itemBuilder: (context, index) {
                    InCartItemData itemData = _cartSingleton.inCartItems[index];
                    return CartItem(
                        shopName: itemData.shop!.getShopName(),
                        itemName: itemData.item!.name!,
                        description: itemData.item!.description!,
                        rating: itemData.rating,
                        location: itemData.shop!.getLocation(),
                        imageUrl: itemData.item!.image!,
                        onChanged: (value) => _toggleItemChecked(index, value),
                        isCheck: _cartSingleton.inCartItems[index].isCheck,
                        price: itemData.item!.price!,
                        stock: itemData.item!.stock!,
                        onDelete: () => _deleteItem(index),
                        onPressed: () => _presenter?.handleItemPressed(_cartSingleton.inCartItems[index]),
                        onChangeAmount: (value) => _presenter?.handleChangeItemAmount(index, value),
                    );
                  },
                ),
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
                  'Select All',
                  style: TextDecor.robo15Medi,
                ),
                Expanded(child: Container()),
                Text("Total: ", style: TextDecor.robo14),
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
                      'Mua hàng (${_presenter?.getCheckedCount()})',
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
    setState(() {
      totalPrice = _presenter!.calculateTotalPrice();
    });
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
    setState(() {
      totalPrice = _presenter!.calculateTotalPrice();
      _selectAll = _cartSingleton.inCartItems.every((element) => element.isCheck);
    });
  }

  @override
  void onLoadDataSucceeded() {
    setState(() {
      totalPrice = _presenter!.calculateTotalPrice();
    });
  }

  @override
  void onItemPressed() {
    Navigator.of(context).pushNamed(DetailProduct.routeName);
  }

  @override
  void onBuyFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onChangeItemAmount() {
    setState(() {
      totalPrice = _presenter!.calculateTotalPrice();
    });
  }
}
