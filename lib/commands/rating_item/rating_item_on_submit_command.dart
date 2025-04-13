import 'package:pcplus/interfaces/command.dart';
import 'package:pcplus/models/orders/order_model.dart';
import 'package:pcplus/pages/rating/rating_presenter.dart';

class RatingItemOnSubmitCommand implements ICommand {
  RatingPresenter presenter;
  OrderModel model;
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