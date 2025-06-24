import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../../commands/rating_item/rating_item_on_submit_command.dart';

class RatingItem extends StatefulWidget {
  final String shopName;
  final String productName;
  final String color;
  final String image;
  final int dayRemain;
  final int buyAmount;
  final RatingItemOnSubmitCommand onSubmit;

  const RatingItem({
    super.key,
    required this.shopName,
    required this.productName,
    required this.color,
    required this.image,
    required this.dayRemain,
    required this.buyAmount,
    required this.onSubmit,
  });

  @override
  State<RatingItem> createState() => _RatingItemState();
}

class _RatingItemState extends State<RatingItem> {
  final TextEditingController _commentController = TextEditingController();
  double? _rating = 5;

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
              ],
            ),
            Row(
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
                SizedBox(
                  width: size.width - 180,
                  height: 125,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.productName,
                        maxLines: 2,
                        textAlign: TextAlign.justify,
                        style: TextDecor.robo16Medi,
                      ),
                      Row(
                        children: [
                          Text(
                            "Phân loại: ${widget.color}",
                            textAlign: TextAlign.justify,
                            maxLines: 2,
                            style: TextDecor.robo14.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(child: Container()),
                          Text(
                            "x2",
                            textAlign: TextAlign.justify,
                            maxLines: 2,
                            style: TextDecor.robo14.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Còn ${widget.dayRemain} ngày để đánh giá!",
                        style: TextDecor.robo16.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(10),
            Row(
              children: [
                Expanded(child: Container()),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 45,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    debugPrint(rating.toString());
                    _rating = rating;
                  },
                ),
                Expanded(child: Container()),
              ],
            ),
            const Gap(10),
            TextField(
              minLines: 1,
              maxLines: 10,
              controller: _commentController,
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8),
                hintText: 'Nhập đánh giá của bạn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Gap(10),
            InkWell(
              onTap: () {
                widget.onSubmit.rating = _rating;
                widget.onSubmit.comment = _commentController.text;
                widget.onSubmit.execute();
              },
              child: Container(
                alignment: Alignment.center,
                height: 45,
                width: size.width,
                decoration: BoxDecoration(
                  color: Palette.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Gửi đánh giá',
                  style: TextDecor.robo17.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
