import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../../interfaces/command.dart';

class ShopItem extends StatelessWidget {
  final String itemName;
  final String imagePath;
  final String location;
  final String description;
  final double rating;
  final int price;
  final int sold;
  final int quantity;
  final ICommand? deleteCommand;
  final ICommand? editCommand;
  final ICommand? pressedCommand;
  final bool isShop;

  const ShopItem(
      {super.key,
      required this.itemName,
      required this.imagePath,
      required this.description,
      required this.quantity,
      required this.location,
      required this.rating,
      required this.price,
      required this.sold,
      this.deleteCommand,
      this.editCommand,
      this.pressedCommand,
      required this.isShop});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        pressedCommand?.execute();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        height: 165,
        width: size.width * 0.425,
        decoration: BoxDecoration(
          color: Palette.backgroundColor.withOpacity(0.2),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: _LazyNetworkImage(
                imageUrl: imagePath,
                width: 130,
                height: 140,
              ),
            ),
            const Gap(6),
            Container(
              width: size.width * 0.425,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemName,
                    maxLines: 1,
                    textAlign: TextAlign.justify,
                    style: TextDecor.robo16Medi,
                  ),
                  Text(
                    description,
                    textAlign: TextAlign.justify,
                    maxLines: 1,
                    style: TextDecor.robo12.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  quantity > 0
                      ? Text(
                          "Còn lại: $quantity",
                          style: TextDecor.robo14.copyWith(
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          "Hết hàng",
                          style: TextDecor.robo14.copyWith(
                            color: Colors.red,
                          ),
                        ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      Text(
                        Utility.formatRatingValue(rating),
                        style: TextDecor.robo14,
                      ),
                      Expanded(child: Container()),
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.black),
                      SizedBox(
                        width: size.width - 300,
                        child: Text(
                          location,
                          maxLines: 1,
                          style: TextDecor.robo14,
                        ),
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
                        Utility.formatCurrency(price),
                        style: TextDecor.robo16Medi.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      Expanded(child: Container()),
                      Text(
                        "Đã bán: ${Utility.formatSoldCount(sold)}",
                        style: TextDecor.robo11,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isShop)
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            editCommand?.execute();
                          },
                          child: const Icon(
                            Icons.edit,
                            size: 30,
                            color: Palette.primaryColor,
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Xóa sản phẩm'),
                                  content: const Text(
                                      'Bạn có muốn xóa sản phẩm này?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        deleteCommand?.execute();
                                      },
                                      child: const Text('Xóa'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Icon(
                            Icons.delete,
                            size: 30,
                            color: Palette.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ✅ LAZY IMAGE WIDGET cho ShopItem
class _LazyNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  const _LazyNetworkImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  State<_LazyNetworkImage> createState() => _LazyNetworkImageState();
}

class _LazyNetworkImageState extends State<_LazyNetworkImage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, color: Colors.grey, size: 28),
        ),
      );
    }

    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      cacheWidth: widget.width.isFinite ? (widget.width * 2).round() : null,
      cacheHeight: widget.height.isFinite ? (widget.height * 2).round() : null,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[100],
          child: Center(
            child: SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey, size: 28),
              SizedBox(height: 6),
              Text(
                'Lỗi tải ảnh',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
