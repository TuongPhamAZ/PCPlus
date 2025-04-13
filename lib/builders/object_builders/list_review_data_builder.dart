
import 'package:pcplus/models/users/user_repo.dart';

import '../../models/ratings/rating_model.dart';
import '../../objects/data_object_interface.dart';
import '../../objects/review_data.dart';
import 'object_builder_interface.dart';

class ListReviewDataBuilder implements ListObjectBuilderInterface {
  List<RatingModel>? ratings = [];
  List<ReviewData>? result = [];

  void setRatingList(List<RatingModel> ratings) {
    this.ratings = ratings;
  }

  Future<void> build() async {
    if (ratings == null) {
      return;
    }

    result = [];
    for (RatingModel model in ratings!) {

      ReviewData data = ReviewData(
          rating: model,
      );
      await data.loadUser(UserRepository());

      result!.add(data);
    }
  }

  @override
  List<IDataObject> createList() {
    if (result == null) {
      return [];
    }
    return result as List<ReviewData>;
  }

  @override
  void reset() {
    ratings = null;
    result = null;
  }
}