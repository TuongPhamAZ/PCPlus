import 'package:flutter/src/widgets/framework.dart';
import 'package:pcplus/builders/widget_builders/widget_builder_interface.dart';
import 'package:pcplus/objects/review_data.dart';

import '../../pages/widgets/listItem/review_item.dart';

class ReviewItemBuilder implements WidgetBuilderInterface {
  ReviewData? reviewData;

  void setReviewData(ReviewData data) {
    reviewData = data;
  }

  @override
  Widget? createWidget() {
    if (reviewData == null) {
      return null;
    }
    return ReviewItem(
        name: reviewData!.user!.name!,
        date: reviewData!.rating!.date!,
        comment: reviewData!.rating!.comment!,
        avatarUrl: reviewData!.user!.avatarUrl,
        rating: reviewData!.rating!.rating!,
    );
  }

  @override
  void reset() {
    reviewData = null;
  }

}