import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../../interfaces/command.dart';

class NewItem extends StatelessWidget {
  final String itemName;
  final String imagePath;
  final String location;
  final double rating;
  final int price;
  final int sold;
  final ICommand? command;

  const NewItem(
      {super.key,
      required this.itemName,
      required this.imagePath,
      required this.location,
      required this.rating,
      required this.price,
      required this.sold,
      this.command});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: command?.execute ?? () {},
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        height: 285,
        width: size.width * 0.425,
        decoration: BoxDecoration(
          color: Palette.backgroundColor.withOpacity(0.8),
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
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                imagePath,
                width: double.infinity,
                height: 165,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Container(
                    height: 105,
                  );
                },
              ),
            ),
            Container(
              height: 118,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    itemName,
                    maxLines: 2,
                    textAlign: TextAlign.justify,
                    style: TextDecor.robo16Medi,
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
                        width: size.width * 0.22,
                        child: Text(
                          location,
                          style: TextDecor.robo14,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.22,
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          Utility.formatCurrency(price),
                          style: TextDecor.robo16Medi.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: size.width * 0.14,
                        child: Text(
                          "Đã bán: ${Utility.formatSoldCount(sold)}",
                          style: TextDecor.robo11,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
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
