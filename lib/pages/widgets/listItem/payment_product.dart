import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/bill/delivery_choice/delivery_choice.dart';
import 'package:pcplus/pages/bill/list_voucher/list_voucher_choice.dart';
import 'package:pcplus/models/vouchers/voucher_model.dart';

import '../../../models/bills/bill_shop_item_model.dart';

class PaymentProductItem extends StatefulWidget {
  final String shopName;
  final List<BillShopItemModel> items;
  final Function(String)? onChangeNote;
  final Function(String, int)? onChangeDeliveryMethod;
  final Function(VoucherModel?)? onVoucherChanged;

  const PaymentProductItem({
    super.key,
    required this.shopName,
    required this.items,
    this.onChangeNote,
    this.onChangeDeliveryMethod,
    this.onVoucherChanged,
  });

  @override
  State<PaymentProductItem> createState() => _PaymentProductItemState();
}

class _PaymentProductItemState extends State<PaymentProductItem> {
  String method = 'Nhanh';
  int deliveryCost = 0;
  VoucherModel? selectedVoucher;

  int _getTotalCost() {
    int sum = 0;
    for (BillShopItemModel item in widget.items) {
      sum += item.price! * item.amount!;
      if (selectedVoucher != null) {
        sum -= selectedVoucher!.discount!;
      }
    }
    return sum;
  }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChangeDeliveryMethod!(method, deliveryCost);
    });

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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.items
                .asMap()
                .entries
                .map((entry) => Row(
                      children: [
                        Container(
                          height: 100,
                          width: 85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: NetworkImage(entry.value.color!.image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Gap(10),
                        SizedBox(
                          width: 263,
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value.name!,
                                style: TextDecor.robo18,
                                maxLines: 2,
                              ),
                              Text(
                                'Loại: ${entry.value.color!.name}',
                                style: TextDecor.robo15.copyWith(
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    Utility.formatCurrency(entry.value.price),
                                    style: TextDecor.robo16Medi.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                  Expanded(child: Container()),
                                  Text('x${entry.value.amount}',
                                      style: TextDecor.robo16Medi),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ))
                .toList(),
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
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shop voucher', style: TextDecor.robo16Medi),
              InkWell(
                onTap: () async {
                  final selectedVoucherResult =
                      await Navigator.push<VoucherModel?>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListVoucherChoice(
                        shopId: 'shop_id',
                        orderAmount: _getTotalCost(),
                        currentSelectedVoucher: selectedVoucher,
                      ),
                    ),
                  );

                  setState(() {
                    selectedVoucher = selectedVoucherResult;
                  });

                  if (widget.onVoucherChanged != null) {
                    widget.onVoucherChanged!(selectedVoucher);
                  }
                },
                child: Row(
                  children: [
                    if (selectedVoucher == null)
                      Text(
                        'None',
                        style: TextDecor.robo15.copyWith(
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '1 voucher applied',
                            style: TextDecor.robo14.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '-${Utility.formatCurrency(selectedVoucher!.discount!)}',
                            style: TextDecor.robo15Medi.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    const Gap(5),
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
                        color: Colors.black.withValues(alpha: 0.5),
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
                            color: Colors.black.withValues(alpha: 0.5),
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
                            color: Colors.black.withValues(alpha: 0.5),
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
                            color: Colors.black.withValues(alpha: 0.5),
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
              Text('Total cost: ', style: TextDecor.robo16Medi),
              Expanded(child: Container()),
              Text(
                Utility.formatCurrency(_getTotalCost() +
                    deliveryCost -
                    (selectedVoucher?.discount ?? 0)),
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
