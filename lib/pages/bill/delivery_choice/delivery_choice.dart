// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class DeliveryChoice extends StatefulWidget {
  final String initialMethod;
  const DeliveryChoice({super.key, this.initialMethod = 'Nhanh'});
  static const String routeName = 'delivery_choice';

  @override
  State<DeliveryChoice> createState() => _DeliveryChoiceState();
}

class _DeliveryChoiceState extends State<DeliveryChoice> {
  late String method;

  @override
  void initState() {
    super.initState();
    method = widget.initialMethod;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Phương thức vận chuyển',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  method = 'Hoa Toc';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Palette.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                  border: method == 'Hoa Toc'
                      ? Border.all(color: Palette.primaryColor, width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
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
            const Gap(10),
            InkWell(
              onTap: () {
                setState(() {
                  method = 'Nhanh';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Palette.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                  border: method == 'Nhanh'
                      ? Border.all(color: Palette.primaryColor, width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
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
            const Gap(10),
            InkWell(
              onTap: () {
                setState(() {
                  method = 'Tiet Kiem';
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Palette.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                  border: method == 'Tiet Kiem'
                      ? Border.all(color: Palette.primaryColor, width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
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
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 58,
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.black,
            ),
          ),
        ),
        child: InkWell(
          onTap: () => Navigator.pop(context, method),
          child: Container(
            alignment: Alignment.center,
            height: 50,
            width: size.width - 20,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('Xác nhận',
                style: TextDecor.robo18Bold.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
