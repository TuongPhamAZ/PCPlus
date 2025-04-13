import 'package:pcplus/interfaces/command.dart';
import 'package:pcplus/pages/notification/notification_screen_presenter.dart';
import '../../models/notification/notification_model.dart';

class NotificationPressedCommand implements ICommand {
  NotificationScreenPresenter presenter;
  NotificationModel model;

  NotificationPressedCommand({
    required this.presenter,
    required this.model,
  });

  @override
  void execute() {
    // TODO: implement execute
    presenter.onNotificationPressed(model);
  }

}