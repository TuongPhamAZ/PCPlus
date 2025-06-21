import 'dart:async';

import 'package:pcplus/const/order_status.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/await_ratings/await_rating_model.dart';
import 'package:pcplus/models/await_ratings/await_rating_repo.dart';
import 'package:pcplus/models/ratings/rating_model.dart';
import 'package:pcplus/pages/user/profile/profile_screen_contract.dart';
import 'package:pcplus/models/bills/bill_repo.dart';
import 'package:pcplus/models/bills/bill_of_shop_repo.dart';
import 'package:pcplus/services/authentication_service.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../models/bills/bill_model.dart';
import '../../../models/bills/bill_of_shop_model.dart';
import '../../../models/users/user_model.dart';

class ProfileScreenPresenter {
  final ProfileScreenContract _view;
  ProfileScreenPresenter(this._view);

  UserModel? user;

  final AuthenticationService _auth = AuthenticationService();
  final BillRepository _billRepository = BillRepository();
  final BillOfShopRepository _billOfShopRepository = BillOfShopRepository();
  final AwaitRatingRepository _awaitRatingRepository = AwaitRatingRepository();

  int awaitConfirm = 0;
  int awaitPickup = 0;
  int awaitDelivery = 0;
  int awaitRating = 0;

  Stream<List<BillModel>>? billStream;
  Stream<List<BillOfShopModel>>? billOfShopStream;
  Stream<List<AwaitRatingModel>>? awaitRatingStream;

  StreamSubscription<List<BillModel>>? _billSubscription;
  StreamSubscription<List<BillOfShopModel>>? _billOfShopSubscription;
  StreamSubscription<List<AwaitRatingModel>>? _awaitRatingSubscription;

  Future<void> getData() async {
    user = await PrefService.loadUserData();

    bool isShop = SessionController.getInstance().isShop();

    if (isShop) {
      // Nếu là shop, sử dụng BillOfShopRepository
      billOfShopStream =
          _billOfShopRepository.getAllBillsOfShopFromShopStream(user!.userID!);
      _billOfShopSubscription = billOfShopStream?.listen((bills) {
        calculateOrderTypeForShop(bills);
      });
    } else {
      // Nếu là user, sử dụng BillRepository
      billStream = _billRepository.getAllBillsFromUserStream(user!.userID!);
      _billSubscription = billStream?.listen((bills) {
        calculateOrderTypeForUser(bills);
      });
      awaitRatingStream = _awaitRatingRepository.getAllAwaitRatingStream(user!.userID!);
      _awaitRatingSubscription = awaitRatingStream?.listen((awaitRatings) {
        calculateAwaitRatingForUser(awaitRatings);
      });
    }

    _view.onLoadDataSucceeded();
  }

  Future<void> calculateOrderTypeForUser(List<BillModel> bills) async {
    awaitRating = 0;
    awaitPickup = 0;
    awaitConfirm = 0;
    awaitDelivery = 0;

    for (BillModel bill in bills) {
      // Đếm số lượng đơn hàng theo trạng thái từ tất cả shop trong bill
      if (bill.shops != null) {
        for (var shop in bill.shops!) {
          String status = shop.status ?? '';
          switch (status) {
            case OrderStatus.PENDING_CONFIRMATION:
              awaitConfirm++;
              break;
            case OrderStatus.AWAIT_PICKUP:
              awaitPickup++;
              break;
            case OrderStatus.AWAIT_DELIVERY:
              awaitDelivery++;
              break;
            case OrderStatus.AWAIT_RATING:
              awaitRating++;
              break;
          }
        }
      }
    }

    // Debug output để kiểm tra
    print(
        'Profile Orders Count - Confirm: $awaitConfirm, Pickup: $awaitPickup, Delivery: $awaitDelivery, Rating: $awaitRating');

    _view.onUpdateOrdersCount();
  }

  Future<void> calculateAwaitRatingForUser(List<AwaitRatingModel> ratings) async {
    awaitRating = ratings.length;

    // Debug output để kiểm tra
    print(
        'Profile Orders Await Rating: $awaitRating');

    _view.onUpdateOrdersCount();
  }

  Future<void> calculateOrderTypeForShop(List<BillOfShopModel> bills) async {
    awaitRating = 0;
    awaitPickup = 0;
    awaitConfirm = 0;
    awaitDelivery = 0;

    for (BillOfShopModel bill in bills) {
      switch (bill.status!) {
        case OrderStatus.PENDING_CONFIRMATION:
          awaitConfirm++;
          break;
        case OrderStatus.AWAIT_PICKUP:
          awaitPickup++;
          break;
        case OrderStatus.AWAIT_DELIVERY:
          awaitDelivery++;
          break;
        case OrderStatus.AWAIT_RATING:
          awaitRating++;
          break;
      }
    }

    // Debug output để kiểm tra
    print(
        'Profile Shop Orders Count - Confirm: $awaitConfirm, Pickup: $awaitPickup, Delivery: $awaitDelivery, Rating: $awaitRating');

    _view.onUpdateOrdersCount();
  }

  Future<void> unsubtopic() async {
    try {
      if (user?.userID != null) {
        final String userTopic = '${user!.userID}';

        await FirebaseMessaging.instance.unsubscribeFromTopic(userTopic);
        _view.onUnsubtopicSucceeded();
      } else {
        throw Exception('User ID is null');
      }
    } catch (e) {
      _view.onUnsubtopicFailed(e.toString());
    }
  }

  void dispose() {
    _billSubscription?.cancel();
    _billOfShopSubscription?.cancel();
    _awaitRatingSubscription?.cancel();
  }

  Future<void> signOut() async {
    _view.onWaitingProgressBar();
    await _auth.signOut();
    await SessionController.getInstance().signOut();
    _view.onPopContext();
    _view.onSignOut();
  }
}
