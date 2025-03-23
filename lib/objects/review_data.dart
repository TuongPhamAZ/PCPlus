import 'package:pcplus/models/ratings/rating_model.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/objects/data_object_interface.dart';

class ReviewData extends DataObjectInterface {
  RatingModel? rating;
  UserModel? user;

  ReviewData({
    required this.rating,
    this.user
  });

 Future<void> loadUser(UserRepository userRepo) async {
   user = await userRepo.getUserById(rating!.userID!);
 }
}