import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../../interfaces/command.dart';

class SuggestItem extends StatelessWidget {
  final String itemName;
  final String imagePath;
  final String location;
  final String description;
  final double rating;
  final int price;
  final int sold;
  final ICommand? command;

  const SuggestItem({
    super.key,
    required this.itemName,
    required this.imagePath,
    required this.description,
    required this.location,
    required this.rating,
    required this.price,
    required this.sold,
    this.command,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: command?.execute ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        height: 140,
        width: size.width * 0.425,
        decoration: BoxDecoration(
          color: Palette.backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.5,
              blurRadius: 1,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: _LazyNetworkImage(
                imageUrl: imagePath,
                width: 100,
                height: 120,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextDecor.robo15.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextDecor.robo11.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        Utility.formatRatingValue(rating),
                        style: TextDecor.robo12.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.black),
                      Flexible(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                          style: TextDecor.robo12.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.sackDollar,
                        size: 12,
                        color: Colors.red,
                      ),
                      const Gap(4),
                      Flexible(
                        flex: 2,
                        child: Text(
                          Utility.formatCurrency(price),
                          overflow: TextOverflow.ellipsis,
                          style: TextDecor.robo14.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Đã bán: ${Utility.formatSoldCount(sold)}",
                        style: TextDecor.robo11,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          child: Icon(Icons.image, color: Colors.grey),
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
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
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
              Icon(Icons.broken_image, color: Colors.grey, size: 24),
              SizedBox(height: 4),
              Text(
                'Lỗi tải ảnh',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
