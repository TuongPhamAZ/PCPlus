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
        padding: const EdgeInsets.all(16),
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
              child: Image.network(
                imagePath,
                width: 130,
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
            const Gap(16),
            SizedBox(
              width: size.width * 0.425,
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
                  Text(
                    description,
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
                        Utility.formatRatingValue(rating),
                        style: TextDecor.robo14,
                      ),
                      Expanded(child: Container()),
                      const Icon(Icons.location_on, size: 18, color: Colors.black),
                      Text(
                        location,
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
          ],
        ),
      ),
    );
  }
}
