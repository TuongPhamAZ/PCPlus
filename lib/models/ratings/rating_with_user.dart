import 'package:pcplus/models/ratings/rating_model.dart';

import '../users/user_model.dart';

class RatingWithUser {
  final RatingModel rating;
  final UserModel user;

  RatingWithUser({required this.rating, required this.user});
}