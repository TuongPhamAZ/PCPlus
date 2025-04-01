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
  final void Function(bool?)? onChanged;
  final void Function()? onDelete;
  final void Function(int amount)? onChangeAmount;
  final void Function()? onPressed;
  const CartItem({
    super.key,
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
    required this.onChangeAmount
  });

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
        margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
        padding: const EdgeInsets.only(top: 10, right: 16, bottom: 10),
        height: 200,
        width: size.width * 0.425,
        decoration: BoxDecoration(
          color: buyable ? Palette.backgroundColor.withOpacity(0.2) : Palette.greyBackground.withOpacity(0.2),
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
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
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
                  Expanded(child: Container()),
                  InkWell(
                    onTap: widget.onDelete,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: widget.isCheck,
                  onChanged: buyable ? widget.onChanged : (value) {},
                )
                ,
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.network(
                    widget.imageUrl,
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
                SizedBox(
                  width: size.width * 0.425,
                  height: 125,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.itemName}${buyable ? "" : " (Sold out)"}",
                        maxLines: 2,
                        textAlign: TextAlign.justify,
                        style: TextDecor.robo16Medi,
                      ),
                      Text(
                        widget.description,
                        textAlign: TextAlign.justify,
                        maxLines: 2,
                        style: TextDecor.robo12.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          Text(
                            Utility.formatRatingValue(widget.rating),
                            style: TextDecor.robo14,
                          ),
                          Expanded(child: Container()),
                          const Icon(Icons.location_on,
                              size: 18, color: Colors.black),
                          Text(
                            widget.location,
                            style: TextDecor.robo14,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.sackDollar,
                            size: 14,
                            color: Colors.red,
                          ),
                          Text(
                            Utility.formatCurrency(widget.price),
                            style: TextDecor.robo16Medi.copyWith(
                              color: Colors.red,
                            ),
                          ),
                          Expanded(child: Container()),
                          GestureDetector(
                            onTap: _decreaseQuantity,
                            child: Container(
                              height: 16,
                              width: 18,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(3),
                                  bottomLeft: Radius.circular(3),
                                ),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            height: 16,
                            width: 18,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 0.5,
                                color: Colors.grey,
                              ),
                            ),
                            child: Text('$soluong',
                                textAlign: TextAlign.center,
                                style: TextDecor.robo11),
                          ),
                          GestureDetector(
                            onTap: _increaseQuantity,
                            child: Container(
                              height: 16,
                              width: 18,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(3),
                                  bottomRight: Radius.circular(3),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 14,
                                color: Colors.black,
                              ),
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
