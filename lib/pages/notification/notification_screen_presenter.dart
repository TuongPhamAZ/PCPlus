import 'dart:async';
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

  // StreamController để quản lý stream lifecycle
  StreamController<List<NotificationModel>>? _notificationController;

  // Stream subscription để dispose
  StreamSubscription<List<NotificationModel>>? _notificationSubscription;

  Stream<List<NotificationModel>>? get notificationStream =>
      _notificationController?.stream;

  bool _isDisposed = false;

  Future<void> getData() async {
    if (_isDisposed) return;

    // Dispose existing streams if any
    await _disposeStreams();

    user = await PrefService.loadUserData();
    isShop = user!.userType == UserType.SHOP;

    // Create new controller
    _notificationController =
        StreamController<List<NotificationModel>>.broadcast();

    // Subscribe to repository stream for real-time updates
    _notificationSubscription = _notificationRepo
        .getAllNotificationsFromUserStream(user!.userID!)
        .listen((data) {
      if (!_isDisposed && !_notificationController!.isClosed) {
        _notificationController!.add(data);
      }
    }, onError: (error) {
      if (!_isDisposed && !_notificationController!.isClosed) {
        _notificationController!.addError(error);
      }
    });

    _view.onLoadDataSucceeded();
  }

  Future<void> onNotificationPressed(NotificationModel model) async {
    model.isRead = true;
    await _notificationRepo.updateNotification(user!.userID!, model);
  }

  // Dispose streams khi không sử dụng nữa
  Future<void> _disposeStreams() async {
    await _notificationSubscription?.cancel();
    await _notificationController?.close();

    _notificationSubscription = null;
    _notificationController = null;
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _disposeStreams();
  }
}
