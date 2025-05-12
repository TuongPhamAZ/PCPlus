import 'package:pcplus/interfaces/command.dart';
import 'package:pcplus/pages/rating/rating_presenter.dart';
import '../../models/await_ratings/await_rating_model.dart';

class RatingItemOnSubmitCommand implements ICommand {
  RatingPresenter presenter;
  AwaitRatingModel model;
  double? rating;
  String? comment;

  RatingItemOnSubmitCommand({
    required this.presenter,
    required this.model,
    this.rating,
    this.comment
  });


  @override
  void execute() {
    presenter.sendRating(model, rating!, comment);
  }

}