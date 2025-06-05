import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../../services/utility.dart';

class CartItem extends StatefulWidget {
  final String shopName;
  final String itemName;
  final String description;
  final double rating;
  final String location;
  final String imageUrl;
  final bool isCheck;
  final int price;
  final int stock;
  final String? color;
  final void Function(bool?)? onChanged;
  final void Function()? onDelete;
  final void Function(int amount)? onChangeAmount;
  final void Function()? onPressed;
  const CartItem(
      {super.key,
      required this.shopName,
      required this.itemName,
      required this.description,
      required this.rating,
      required this.location,
      required this.imageUrl,
      required this.onChanged,
      required this.onPressed,
      required this.isCheck,
      required this.price,
      required this.stock,
      required this.onDelete,
      required this.onChangeAmount,
      this.color});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  int soluong = 1;
  bool buyable = false;

  @override
  void initState() {
    _checkSoldOut();
    super.initState();
  }

  void _checkSoldOut() {
    buyable = soluong <= widget.stock;
  }

  void _decreaseQuantity() {
    setState(() {
      if (soluong > 1) {
        soluong--;
        widget.onChangeAmount!(soluong);
        _checkSoldOut();
      }
    });
  }

  void _increaseQuantity() {
    setState(() {
      if (soluong < widget.stock) {
        soluong++;
        widget.onChangeAmount!(soluong);
        _checkSoldOut();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: buyable
              ? Palette.containerBackground
              : Palette.greyBackground.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: buyable
                ? Palette.main1.withOpacity(0.3)
                : Palette.greyBackground,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Palette.primaryColor.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Palette.main1.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.store_rounded,
                        color: Palette.primaryColor,
                        size: 14,
                      ),
                      const Gap(4),
                      Text(
                        widget.shopName,
                        style: TextDecor.robo12.copyWith(
                          color: Palette.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: widget.onDelete,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Palette.billOrange,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: widget.isCheck,
                    onChanged: buyable ? widget.onChanged : (value) {},
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    activeColor: Palette.primaryColor,
                  ),
                ),
                const Gap(6),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Palette.primaryColor.withOpacity(0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.imageUrl,
                      width: 85,
                      height: 85,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            color: Palette.greyBackground.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: Palette.hintText,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.itemName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextDecor.robo16Medi.copyWith(
                                color:
                                    buyable ? Colors.black87 : Palette.hintText,
                              ),
                            ),
                          ),
                          if (!buyable)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Palette.billOrange.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Hết hàng',
                                style: TextDecor.robo12.copyWith(
                                  color: Palette.billOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        widget.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextDecor.robo12.copyWith(
                          color: Palette.hintText,
                          height: 1.2,
                        ),
                      ),
                      if (widget.color != null) ...[
                        Row(
                          children: [
                            Text(
                              'Màu: ',
                              style: TextDecor.robo13Medi.copyWith(
                                color: Palette.main2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.color!,
                              style: TextDecor.robo13Medi.copyWith(
                                color: Palette.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Palette.star),
                          const Gap(2),
                          Text(
                            Utility.formatRatingValue(widget.rating),
                            style: TextDecor.robo13Medi.copyWith(
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          const Gap(8),
                          const Icon(Icons.location_on_rounded,
                              size: 16, color: Palette.star),
                          const Gap(2),
                          Expanded(
                            child: Text(
                              widget.location,
                              style: TextDecor.robo12.copyWith(
                                color: Palette.main2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.sackDollar,
                                  size: 14,
                                  color: Palette.billOrange,
                                ),
                                const Gap(3),
                                Flexible(
                                  child: Text(
                                    Utility.formatCurrency(widget.price),
                                    style: TextDecor.robo15Medi.copyWith(
                                      color: Palette.billOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Palette.main1.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: _decreaseQuantity,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    bottomLeft: Radius.circular(6),
                                  ),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: soluong > 1
                                          ? Palette.primaryColor
                                          : Palette.hintText,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 32,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.symmetric(
                                      vertical: BorderSide(
                                          color:
                                              Palette.main1.withOpacity(0.4)),
                                    ),
                                  ),
                                  child: Text(
                                    '$soluong',
                                    style: TextDecor.robo13Medi.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _increaseQuantity,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(6),
                                    bottomRight: Radius.circular(6),
                                  ),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.add,
                                      size: 16,
                                      color: soluong < widget.stock
                                          ? Palette.primaryColor
                                          : Palette.hintText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
