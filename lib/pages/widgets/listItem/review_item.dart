import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/services/utility.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class ReviewItem extends StatefulWidget {
  final double? rating;
  final String name;
  final DateTime date;
  final String comment;
  final String? avatarUrl;

  const ReviewItem({
    super.key,
    required this.name,
    required this.date,
    required this.comment,
    this.avatarUrl,
    this.rating
  });

  @override
  State<ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<ReviewItem> {
  double rating = 3.5;

  @override
  void initState() {
    rating = widget.rating ?? 3.5;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Palette.borderBackBtn,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: (
                        widget.avatarUrl != null ?
                          const AssetImage(AssetHelper.defaultAvt)
                          :
                          NetworkImage(widget.avatarUrl!)
                    ) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Gap(10),
              Text(
                widget.name,
                style: TextDecor.robo16,
              ),
            ],
          ),
          Row(
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 18,
                unratedColor: Palette.primaryColor,
                itemBuilder: (context, index) {
                  if (index < rating) {
                    return const Icon(
                      Icons.star,
                      color: Colors.amber,
                    );
                  } else {
                    return const Icon(
                      Icons.star_border_outlined,
                    );
                  }
                },
                ignoreGestures: true,
                onRatingUpdate: (rating) {},
              ),
              const Gap(4),
              Text(
                Utility.formatDateFromDateTime(widget.date),
                style: TextDecor.robo15,
              ),
            ],
          ),
          const Gap(8),
          Text(
            widget.comment,
            style: TextDecor.robo15.copyWith(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
