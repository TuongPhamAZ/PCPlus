import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/commands/history_order_item/cancel_order_command.dart';
import 'package:pcplus/commands/history_order_item/received_order_command.dart';
import 'package:pcplus/commands/history_order_item/sent_order_command.dart';
import 'package:pcplus/commands/history_order_item/validate_order_command.dart';
import 'package:pcplus/const/order_status.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../../models/bills/bill_shop_item_model.dart';

class HistoryItem extends StatefulWidget {
  final String shopName;
  final String receiverName;
  final String status;
  final List<BillShopItemModel> products;
  // final String productName;
  final String address;
  final int price;
  final String image;
  final bool isShop;
  final ValidateOrderCommand? onValidateOrder;
  final CancelOrderCommand? onCancelOrder;
  final ReceivedOrderCommand? onReceivedOrder;
  final SentOrderCommand? onSentOrder;
  const HistoryItem({
    super.key,
    required this.shopName,
    required this.status,
    required this.products,
    required this.address,
    required this.receiverName,
    required this.price,
    required this.isShop,
    required this.image,
    this.onValidateOrder,
    this.onCancelOrder,
    this.onReceivedOrder,
    this.onSentOrder,
  });

  @override
  State<HistoryItem> createState() => _HistoryItemState();
}

class _HistoryItemState extends State<HistoryItem> {
  bool isShop = true;
  bool choXacNhan = false;
  bool choLayHang = false;
  bool choGiaoHang = false;
  bool choDanhGia = false;
  bool choDuyetDon = false;
  bool choGuiHang = false;
  String status = "status";

  @override
  void initState() {
    isShop = widget.isShop;
    if (isShop) {
      switch (widget.status) {
        case OrderStatus.PENDING_CONFIRMATION:
          setState(() {
            status = "Chờ duyệt đơn";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = false;
            choDanhGia = false;
            choDuyetDon = true;
            choGuiHang = false;
          });
          break;
        case OrderStatus.AWAIT_PICKUP:
          setState(() {
            status = "Chờ gửi hàng";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = false;
            choDanhGia = false;
            choDuyetDon = false;
            choGuiHang = true;
          });
          break;
        case OrderStatus.AWAIT_DELIVERY:
          setState(() {
            status = "Chờ giao hàng";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = true;
            choDanhGia = false;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
        case OrderStatus.AWAIT_RATING:
          setState(() {
            status = "Chờ đánh giá";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = false;
            choDanhGia = true;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
        case OrderStatus.COMPLETED:
          setState(() {
            status = "Hoàn thành";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = false;
            choDanhGia = false;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
        default:
          setState(() {
            status = "Đã Hủy";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = false;
            choDanhGia = false;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
      }
    } else {
      switch (widget.status) {
        case OrderStatus.PENDING_CONFIRMATION:
          setState(() {
            status = "Chờ xác nhận";
            choXacNhan = true;
            choLayHang = false;
            choGiaoHang = false;
            choDanhGia = false;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
        case OrderStatus.AWAIT_PICKUP:
          setState(() {
            status = "Chờ lấy hàng";
            choXacNhan = false;
            choLayHang = true;
            choGiaoHang = false;
            choDanhGia = false;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
        case OrderStatus.AWAIT_DELIVERY:
          setState(() {
            status = "Chờ giao hàng";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = true;
            choDanhGia = false;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
        case OrderStatus.AWAIT_RATING:
          setState(() {
            status = "Chờ đánh giá";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = false;
            choDanhGia = true;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
        case OrderStatus.COMPLETED:
          setState(() {
            status = "Hoàn thành";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = false;
            choDanhGia = false;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
        default:
          setState(() {
            status = "Đã Hủy";
            choXacNhan = false;
            choLayHang = false;
            choGiaoHang = false;
            choDanhGia = false;
            choDuyetDon = false;
            choGuiHang = false;
          });
          break;
      }
    }

    super.initState();
  }

  void _showCancelOrderDialog(BuildContext context) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xác nhận huỷ đơn hàng"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Vui lòng nhập lý do huỷ:"),
              const SizedBox(height: 10),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Nhập lý do...",
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                String reason = reasonController.text;
                Navigator.of(context).pop(); // Đóng dialog
                // Thực hiện logic với lý do huỷ
                widget.onCancelOrder!.reason = reason;
                widget.onCancelOrder!.execute();
                debugPrint("Lý do huỷ đơn: $reason");
              },
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        width: size.width - 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(4, 3),
            ),
          ],
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
                ),
                const Spacer(),
                Text(
                  status,
                  style: TextDecor.robo14.copyWith(color: Colors.red),
                ),
              ],
            ),
            if (isShop)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size.width - 180,
                    child: Text(
                      "Đến: ${widget.receiverName}",
                      style: TextDecor.robo17,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    width: size.width - 180,
                    child: Text(
                      widget.address,
                      style: TextDecor.robo17,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.network(
                    widget.image,
                    width: 125,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Container(
                        height: 105,
                      );
                    },
                  ),
                ),
                const Gap(10),
                Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      children: widget.products
                          .asMap()
                          .entries
                          .map((entry) => SizedBox(
                                width: size.width - 180,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: size.width - 20,
                                      child: Text(
                                        entry.value.name!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.justify,
                                        style: TextDecor.robo16Medi,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Phân loại: ${entry.value.color!.name!}",
                                          textAlign: TextAlign.justify,
                                          maxLines: 2,
                                          style: TextDecor.robo14.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Expanded(child: Container()),
                                        Text(
                                          "x${entry.value.amount!}",
                                          textAlign: TextAlign.justify,
                                          maxLines: 2,
                                          style: TextDecor.robo14.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Container()),
                Text(
                  "Đơn giá: ${Utility.formatCurrency(widget.price)}",
                  style: TextDecor.robo17Medi,
                ),
              ],
            ),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isShop && !choDuyetDon) Expanded(child: Container()),
                if (isShop && choDuyetDon)
                  SizedBox(
                    width: size.width - 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            _showCancelOrderDialog(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 45,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Huỷ đơn hàng',
                              style: TextDecor.robo16Semi,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            widget.onValidateOrder!.execute();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 45,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Palette.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Duyệt đơn',
                              style: TextDecor.robo16Semi,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isShop && choGuiHang)
                  Container(
                    width: size.width - 80,
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        widget.onSentOrder!.execute();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 45,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Palette.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Đã gửi hàng',
                          style: TextDecor.robo16Semi,
                        ),
                      ),
                    ),
                  ),
                if (!isShop && choLayHang)
                  Container(
                    width: size.width - 80,
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        _showCancelOrderDialog(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 45,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Palette.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Huỷ Đơn Hàng',
                          style: TextDecor.robo16Semi,
                        ),
                      ),
                    ),
                  ),
                if (!isShop && choGiaoHang)
                  Container(
                    width: size.width - 80,
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        widget.onReceivedOrder!.execute();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 45,
                        width: 160,
                        decoration: BoxDecoration(
                          color: Palette.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Đã nhận được hàng',
                          style: TextDecor.robo16Semi,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
