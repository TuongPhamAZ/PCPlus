import 'package:pcplus/const/order_status.dart';
import 'package:pcplus/pages/user/profile/profile_screen_contract.dart';
import 'package:pcplus/models/orders/order_repo.dart';
import 'package:pcplus/services/authentication_service.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/singleton/user_singleton.dart';

import '../../../models/orders/order_model.dart';
import '../../../models/users/user_model.dart';

class ProfileScreenPresenter {
  final ProfileScreenContract _view;
  ProfileScreenPresenter(this._view);

  UserModel? user;

  final AuthenticationService _auth = AuthenticationService();
  final OrderRepository _orderRepository = OrderRepository();

  int awaitConfirm = 0;
  int awaitPickup = 0;
  int awaitDelivery = 0;
  int awaitRating = 0;

  Stream<List<OrderModel>>? orderStream;

  Future<void> getData() async {
    user = await PrefService.loadUserData();

    orderStream = _orderRepository.getAllOrdersFromUserStream(user!.userID!);

    orderStream?.listen((snapshot) {
      calculateOrderType(snapshot);
    });

    _view.onLoadDataSucceeded();
  }

  Future<void> calculateOrderType(List<OrderModel> orders) async {
    awaitRating = 0;
    awaitPickup = 0;
    awaitConfirm = 0;
    awaitDelivery = 0;
    for (OrderModel order in orders) {
      switch (order.status!) {
        case OrderStatus.PENDING_CONFIRMATION:
          awaitConfirm ++;
          break;
        case OrderStatus.AWAIT_PICKUP:
          awaitPickup ++;
          break;
        case OrderStatus.AWAIT_DELIVERY:
          awaitDelivery ++;
          break;
        case OrderStatus.AWAIT_RATING:
          awaitRating ++;
          break;
      }
    }
    _view.onUpdateOrdersCount();
  }

  Future<void> signOut() async {
    _view.onWaitingProgressBar();
    await _auth.signOut();
    await PrefService.clearUserData();
    await UserSingleton.getInstance().signOut();
    _view.onPopContext();
    _view.onSignOut();
  }
}