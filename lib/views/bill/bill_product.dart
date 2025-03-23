import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/contract/bill_product_contract.dart';
import 'package:pcplus/objects/in_cart_item_data.dart';
import 'package:pcplus/presenter/bill_product_presenter.dart';
import 'package:pcplus/singleton/cart_singleton.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/views/delivery/delivery_infor.dart';
import 'package:pcplus/models/orders/order_address_model.dart';
import 'package:pcplus/views/home.dart';
import 'package:pcplus/views/widgets/listItem/payment_product.dart';

import '../widgets/util_widgets.dart';

class BillProduct extends StatefulWidget {
  const BillProduct({super.key});
  static const String routeName = 'bill_product';

  @override
  State<BillProduct> createState() => _BillProductState();
}

class _BillProductState extends State<BillProduct> implements BillProductContract {
  BillProductPresenter? _presenter;
  final CartSingleton _cartSingleton = CartSingleton.getInstance();

  int productCount = 2;
  bool isFirst = true;
  OrderAddressModel address = OrderAddressModel(
    receiverName: "",
    phone: "",
    address1: "",
    address2: "",
  );

  @override
  void initState() {
    if (_cartSingleton.address != null) {
      address = _cartSingleton.address!;
      isFirst = false;
    }
    _presenter = BillProductPresenter(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () {
            _presenter?.handleBack();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            InkWell(
              onTap: () async {
                //Go to Address Edit
                final updatedAddress = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryInfor(
                      currentAddress: address,
                    ),
                  ),
                );

                // Nếu có địa chỉ mới, cập nhật lại thông tin
                if (updatedAddress != null) {
                  setState(() {
                    address = updatedAddress.first;
                    _presenter!.handleChangeLocation(address);
                    isFirst = false;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Palette.primaryColor,
                      size: 30,
                    ),
                    const Gap(8),
                    SizedBox(
                      width: size.width * 0.847,
                      child: !isFirst
                          ? Row(
                              children: [
                                SizedBox(
                                  width: size.width * 0.75,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${address.receiverName}',
                                            style: TextDecor.robo18Semi,
                                          ),
                                          const Gap(10),
                                          Text(
                                            '${address.phone}',
                                            style: TextDecor.robo16.copyWith(
                                              color: Palette.hintText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text('${address.address1}',
                                          style: TextDecor.robo15),
                                      Text('${address.address2}',
                                          style: TextDecor.robo15),
                                    ],
                                  ),
                                ),
                                Expanded(child: Container()),
                                const Icon(
                                  FontAwesomeIcons.angleRight,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              ],
                            )
                          : Text(
                              'Vui lòng chọn địa chỉ giao hàng!!!',
                              style: TextDecor.robo18Semi,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(5),
            SizedBox(
              height: 6,
              width: size.width,
              child: ListView.builder(
                itemCount: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    height: 6,
                    width: (size.width - 27) * 0.1,
                    decoration: BoxDecoration(
                      color: (index % 2 == 0)
                          ? Palette.billBlue
                          : Palette.billOrange,
                    ),
                  );
                },
              ),
            ),
            ListView.builder(
              itemCount: _cartSingleton.onPaymentItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                InCartItemData data = _cartSingleton.onPaymentItems[index];
                return PaymentProductItem(
                  productName: data.item!.name!,
                  shopName: data.shop!.getShopName(),
                  price: data.item!.price!,
                  amount: data.amount,
                  imageUrl: data.item!.image!,
                  onChangeNote: (text) {
                    _presenter?.handleNoteForShop(data: data, text: text);
                  },
                  onChangeDeliveryMethod: (method, price) {
                    _presenter?.handleChangeDelivery(
                        data: data,
                        deliveryMethod: method,
                        cost: price
                    );
                  },
                  color: "Black",
                );
              },
            ),
            const Gap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Method', style: TextDecor.robo18Semi),
                  const Gap(5),
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.moneyBill,
                        color: Colors.red,
                        size: 30,
                      ),
                      const Gap(8),
                      Text('Cash on delivery', style: TextDecor.robo16),
                    ],
                  ),
                  const Gap(12),
                  Text('Payment Detail', style: TextDecor.robo18Semi),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Product cost:', style: TextDecor.robo16),
                                const Gap(5),
                                Text('Shipping fee:', style: TextDecor.robo16),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_presenter!.getProductCost(), style: TextDecor.robo16),
                                const Gap(5),
                                Text(_presenter!.getShippingFee(), style: TextDecor.robo16),
                              ],
                            ),
                          ],
                        ),
                        const Gap(10),
                        const Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                        Row(
                          children: [
                            Text('Total:', style: TextDecor.robo18Semi),
                            Expanded(child: Container()),
                            Text(_presenter!.getTotalCost(), style: TextDecor.robo18Semi),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        width: size.width,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Total:', style: TextDecor.robo18Semi),
            const Gap(5),
            Text(
              _presenter!.getTotalCost(),
              style: TextDecor.robo18Semi.copyWith(
                color: Colors.red,
              ),
            ),
            const Gap(10),
            InkWell(
              onTap: () {
                //Go to Order
                _presenter?.handleOrder(address);
              },
              child: Container(
                alignment: Alignment.center,
                height: 60,
                width: size.width * 0.333,
                decoration: const BoxDecoration(
                  color: Palette.primaryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  'Order',
                  style: TextDecor.robo24Medi.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onBuy() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(HomeScreen.routeName);// Đóng dialog
        });
        return AlertDialog(
          alignment: Alignment.center,
          content: Container(
            alignment: Alignment.center,
            height: 120,
            child: Column(
              children: [
                Expanded(child: Container()),
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 50,
                ),
                const Gap(10),
                Text(
                  'Order thành công!',
                  style: TextDecor.robo18Semi.copyWith(
                    color: Colors.white,
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
          backgroundColor: Colors.black.withOpacity(0.45),
        );
      },
    );
  }

  @override
  void onBuyFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
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
  void onBack() {
    Navigator.pop(context);
  }

  @override
  void onChangeData() {
    if (context.mounted == false) {
      return;
    }
    setState(() {});
  }
}
