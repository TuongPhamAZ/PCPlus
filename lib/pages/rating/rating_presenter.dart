import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/await_ratings/await_rating_repo.dart';
import 'package:pcplus/models/ratings/rating_model.dart';
import 'package:pcplus/models/ratings/rating_repo.dart';
import 'package:pcplus/pages/rating/rating_contract.dart';
import '../../models/await_ratings/await_rating_model.dart';
import '../../models/orders/order_model.dart';
import '../../services/utility.dart';

class RatingPresenter {
  final RatingScreenContract _view;
  RatingPresenter(this._view);

  final AwaitRatingRepository _awaitRatingRepo = AwaitRatingRepository();
  final SessionController _sessionController = SessionController.getInstance();
  final RatingRepository _ratingRepo = RatingRepository();

  Stream<List<AwaitRatingModel>>? awaitRatingStream;

  Future<void> getData() async {
    awaitRatingStream = _awaitRatingRepo.getAllAwaitRatingStream(_sessionController.userID!);

    List<AwaitRatingModel> items = await _awaitRatingRepo.getAllAwaitRating(_sessionController.userID!);

    for (AwaitRatingModel item in items) {
      if (Utility.calculateDuration(item.createdAt!, DateTime.now()).inDays - 30 > 0) {
        await _awaitRatingRepo.deleteAwaitRatingByKey(SessionController.getInstance().userID!, item.key!);
      }
    }
  }

  Future<void> sendRating(AwaitRatingModel model, double rating, String? comment) async {
    _view.onWaitingProgressBar();
    RatingModel ratingModel = RatingModel(
        userID: _sessionController.userID,
        itemID: model.item!.itemID!,
        rating: rating,
        date: DateTime.now(),
        comment: comment ?? "",
        like: [],
        dislike: [],
    );
    await _ratingRepo.addRatingToFirestore(model.item!.itemID!, ratingModel);
    await _awaitRatingRepo.deleteAwaitRatingByKey(_sessionController.userID!, model.key!);
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }
}