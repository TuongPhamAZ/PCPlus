import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/views/bill/delivery_choice.dart';

class PaymentProductItem extends StatefulWidget {
  final String shopName;
  final String productName;
  final String imageUrl;
  final String color;
  final int price;
  final int amount;
  final Function(String)? onChangeNote;
  final Function(String, int)? onChangeDeliveryMethod;
  const PaymentProductItem({
    super.key,
    required this.shopName,
    required this.productName,
    required this.imageUrl,
    required this.color,
    required this.price,
    required this.amount,
    this.onChangeNote,
    this.onChangeDeliveryMethod,
  });

  @override
  State<PaymentProductItem> createState() => _PaymentProductItemState();
}

class _PaymentProductItemState extends State<PaymentProductItem> {
  String method = 'Nhanh';
  int deliveryCost = 0;
  @override
  Widget build(BuildContext context) {
    switch (method) {
      case 'Nhanh':
        deliveryCost = 25000;
        break;
      case 'Tiet Kiem':
        deliveryCost = 12500;
        break;
      case 'Hoa Toc':
        deliveryCost = 120000;
        break;
    }
    widget.onChangeDeliveryMethod!(method, deliveryCost);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Palette.borderBackBtn,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.house,
                color: Colors.black,
                size: 30,
              ),
              const Gap(5),
              Text(
                widget.shopName,
                style: TextDecor.robo17Medi,
              )
            ],
          ),
          const Gap(5),
          Row(
            children: [
              Container(
                height: 100,
                width: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Gap(10),
              SizedBox(
                width: 268,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.productName,
                      style: TextDecor.robo18,
                      maxLines: 2,
                    ),
                    Text(
                      'Kind: Black',
                      style: TextDecor.robo15.copyWith(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          Utility.formatCurrency(widget.price),
                          style: TextDecor.robo16Medi.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        Expanded(child: Container()),
                        Text('x${widget.amount}', style: TextDecor.robo16Medi),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(
            color: Palette.borderBackBtn,
            thickness: 1,
          ),
          const Gap(5),
          Text('Note for shop', style: TextDecor.robo16Medi),
          TextField(
            minLines: 1,
            maxLines: 100,
            style: TextDecor.robo15,
            onChanged: (text) {
              widget.onChangeNote!(text);
            },
            onTapOutside: (event) {
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(8),
              hintText: 'Write your note here',
              hintStyle: TextDecor.robo15.copyWith(
                color: Palette.hintText,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  color: Palette.borderBackBtn,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ),
          const Gap(3),
          const Divider(
            color: Palette.borderBackBtn,
            thickness: 1,
          ),
          const Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery method', style: TextDecor.robo16Medi),
              InkWell(
                onTap: () async {
                  final selectedMethod = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeliveryChoice(
                        initialMethod: method,
                      ),
                    ),
                  );
                  if (selectedMethod != null) {
                    setState(() {
                      method = selectedMethod;
                    });
                  }
                },
                child: Row(
                  children: [
                    Text(
                      'View all ',
                      style: TextDecor.robo15.copyWith(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    const Icon(
                      FontAwesomeIcons.angleRight,
                      color: Colors.grey,
                      size: 17,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(5),
          if (method == 'Nhanh')
            InkWell(
              onTap: () async {
                final selectedMethod = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryChoice(
                      initialMethod: method,
                    ),
                  ),
                );
                if (selectedMethod != null) {
                  setState(() {
                    method = selectedMethod;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Palette.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giao hàng nhanh', style: TextDecor.robo16Medi),
                        const Gap(5),
                        Text(
                          'Đảm bảo nhận hàng sau 1-3 ngày',
                          style: TextDecor.robo15.copyWith(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: Container()),
                    Text('25.000 VNĐ', style: TextDecor.robo16Medi),
                  ],
                ),
              ),
            ),
          if (method == 'Hoa Toc')
            InkWell(
              onTap: () async {
                final selectedMethod = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryChoice(
                      initialMethod: method,
                    ),
                  ),
                );
                if (selectedMethod != null) {
                  setState(() {
                    method = selectedMethod;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Palette.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giao hàng hoả tốc', style: TextDecor.robo16Medi),
                        const Gap(5),
                        Text(
                          'Đảm bảo nhận hàng sau 3-10 giờ',
                          style: TextDecor.robo15.copyWith(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: Container()),
                    Text('120.000 VNĐ', style: TextDecor.robo16Medi),
                  ],
                ),
              ),
            ),
          if (method == 'Tiet Kiem')
            InkWell(
              onTap: () async {
                final selectedMethod = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryChoice(
                      initialMethod: method,
                    ),
                  ),
                );
                if (selectedMethod != null) {
                  setState(() {
                    method = selectedMethod;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Palette.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giao hàng tiết kiệm',
                            style: TextDecor.robo16Medi),
                        const Gap(5),
                        Text(
                          'Đảm bảo nhận hàng sau 5-7 ngày',
                          style: TextDecor.robo15.copyWith(
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: Container()),
                    Text('12.500 VNĐ', style: TextDecor.robo16Medi),
                  ],
                ),
              ),
            ),
          const Divider(
            color: Palette.borderBackBtn,
            thickness: 1,
          ),
          const Gap(10),
          Row(
            children: [
              Text('Total cost (${widget.amount} products)', style: TextDecor.robo16Medi),
              Expanded(child: Container()),
              Text(
                Utility.formatCurrency(widget.amount * widget.price + deliveryCost),
                style: TextDecor.robo16Medi.copyWith(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
