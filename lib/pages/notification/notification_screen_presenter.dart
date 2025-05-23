import 'package:pcplus/pages/notification/notification_screen_contract.dart';
import 'package:pcplus/models/notification/notification_repo.dart';
import 'package:pcplus/services/pref_service.dart';

import '../../models/notification/notification_model.dart';
import '../../models/users/user_model.dart';

class NotificationScreenPresenter {
  final NotificationScreenContract _view;
  NotificationScreenPresenter(this._view);

  final NotificationRepository _notificationRepo = NotificationRepository();

  UserModel? user;
  bool isShop = false;

  Stream<List<NotificationModel>>? notificationStream;

  Future<void> getData() async {
    user = await PrefService.loadUserData();

    isShop = user!.userType == UserType.SHOP;
    notificationStream = _notificationRepo.getAllNotificationsFromUserStream(user!.userID!);

    _view.onLoadDataSucceeded();
  }

  Future<void> onNotificationPressed(NotificationModel model) async {
    model.isRead = true;
    await _notificationRepo.updateNotification(user!.userID!, model);
  }
}