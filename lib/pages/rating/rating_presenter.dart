import 'package:pcplus/const/order_status.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/orders/order_repo.dart';
import 'package:pcplus/models/ratings/rating_model.dart';
import 'package:pcplus/models/ratings/rating_repo.dart';
import 'package:pcplus/pages/rating/rating_contract.dart';
import '../../models/orders/order_model.dart';

class RatingPresenter {
  final RatingScreenContract _view;
  RatingPresenter(this._view);

  final SessionController _sessionController = SessionController.getInstance();
  final OrderRepository _orderRepo = OrderRepository();
  final RatingRepository _ratingRepo = RatingRepository();

  List<OrderModel> orders = [];

  Stream<List<OrderModel>>? orderStream;

  Future<void> getData() async {
    orderStream = null;
  }

  Future<void> updateOrder(OrderModel model, String status) async {
    model.status = status;
    await _orderRepo.updateOrder(model.receiverID!, model);
    await _orderRepo.updateOrder(model.itemModel!.sellerID!, model);
  }

  Future<void> sendRating(OrderModel model, double rating, String? comment) async {
    _view.onWaitingProgressBar();
    RatingModel ratingModel = RatingModel(
        userID: _sessionController.userID,
        itemID: model.itemModel!.itemID!,
        rating: rating,
        date: DateTime.now(),
        comment: comment ?? ""
    );
    await _ratingRepo.addRatingToFirestore(model.itemModel!.itemID!, ratingModel);
    await updateOrder(model, OrderStatus.COMPLETED);
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }
}