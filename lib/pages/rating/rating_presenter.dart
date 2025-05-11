import 'package:pcplus/const/order_status.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/bills/bill_of_shop_model.dart';
import 'package:pcplus/models/bills/bill_of_shop_repo.dart';
import 'package:pcplus/models/orders/order_repo.dart';
import 'package:pcplus/models/ratings/rating_model.dart';
import 'package:pcplus/models/ratings/rating_repo.dart';
import 'package:pcplus/pages/rating/rating_contract.dart';
import '../../models/bills/bill_model.dart';
import '../../models/bills/bill_repo.dart';
import '../../models/bills/bill_shop_item_model.dart';
import '../../models/orders/order_model.dart';

class RatingPresenter {
  final RatingScreenContract _view;
  RatingPresenter(this._view);

  final SessionController _sessionController = SessionController.getInstance();
  final BillRepository _billRepo = BillRepository();
  final BillOfShopRepository _billOfShopRepo = BillOfShopRepository();
  final RatingRepository _ratingRepo = RatingRepository();

  List<OrderModel> orders = [];

  Stream<List<BillModel>>? billStream;

  Future<void> getData() async {
    billStream = null;
  }

  Future<void> updateBill(BillModel model, String shopID, String status) async {
    // model.status = status;

    BillOfShopModel? billOfShopModel = model.toBillOfShopModel(shopID);

    if (billOfShopModel == null) {
      return;
    }

    await _billRepo.updateBill(model.userID!, model);
    await _billOfShopRepo.updateBillOfShop(shopID, billOfShopModel);
  }

  Future<void> sendRating(BillModel model, double rating, String? comment) async {
    _view.onWaitingProgressBar();
    // RatingModel ratingModel = RatingModel(
    //     userID: _sessionController.userID,
    //     itemID: model.item,
    //     rating: rating,
    //     date: DateTime.now(),
    //     comment: comment ?? "",
    //     like: [],
    //     dislike: [],
    // );
    // await _ratingRepo.addRatingToFirestore(model.itemModel!.itemID!, ratingModel);
    // await updateBill(model, OrderStatus.COMPLETED);
    _view.onPopContext();
    _view.onLoadDataSucceeded();
  }
}