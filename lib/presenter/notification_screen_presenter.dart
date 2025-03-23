import 'package:pcplus/contract/notification_screen_contract.dart';
import 'package:pcplus/models/notification/notification_repo.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/singleton/user_singleton.dart';

import '../models/notification/notification_model.dart';
import '../models/users/user_model.dart';

class NotificationScreenPresenter {
  final NotificationScreenContract _view;
  NotificationScreenPresenter(this._view);

  final PrefService _pref = PrefService();

  final NotificationRepository _notificationRepo = NotificationRepository();
  final UserSingleton _userSingleton = UserSingleton.getInstance();

  UserModel? get user => _userSingleton.currentUser;
  bool isShop = false;

  List<NotificationModel> notifications = [];

  Future<void> getData() async {
    isShop = user!.isSeller!;
    notifications = await _notificationRepo.getAllNotificationsFromUser(user!.userID!);

    _view.onLoadDataSucceeded();
  }
}