import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/commands/notification/notification_pressed_command.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/pages/notification/notification_screen_contract.dart';
import 'package:pcplus/models/notification/notification_model.dart';
import 'package:pcplus/pages/notification/notification_screen_presenter.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/notification/confirm.dart';

import '../widgets/bottom/bottom_bar_custom.dart';
import '../widgets/bottom/shop_bottom_bar.dart';
import '../widgets/util_widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  static const String routeName = 'notification_screen';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    implements NotificationScreenContract {
  NotificationScreenPresenter? _presenter;

  bool isShop = false;
  bool isLoading = true;

  bool _isFirstLoad = true;

  @override
  void initState() {
    _presenter = NotificationScreenPresenter(this);
    isShop = SessionController.getInstance().isShop();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      loadData();
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    _presenter?.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (mounted) {
      await _presenter?.getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thông báo',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.grey.withOpacity(0.0),
        ),
        child: StreamBuilder<List<NotificationModel>>(
            stream: _presenter!.notificationStream,
            builder: (context, snapshot) {
              Widget? result =
                  UtilWidgets.createSnapshotResultWidget(context, snapshot);
              if (result != null) {
                return result;
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const Gap(24),
                        Text(
                          'Chưa có thông báo nào',
                          style: TextDecor.robo18Semi.copyWith(
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(12),
                        Text(
                          'Bạn sẽ nhận được thông báo về đơn hàng, khuyến mãi và tin tức mới nhất tại đây',
                          style: TextDecor.robo14.copyWith(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(32),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  NotificationModel model = notifications[index];
                  return ConfirmNoti(
                    title: model.title!,
                    image: model.productImage!,
                    date: model.date!,
                    content: model.content!,
                    isView: model.isRead!,
                    onPressed: NotificationPressedCommand(
                      presenter: _presenter!,
                      model: model,
                    ),
                  );
                },
              );
            }),
      ),
      bottomNavigationBar: isShop
          ? const ShopBottomBar(currentIndex: 2)
          : const BottomBarCustom(currentIndex: 2),
    );
  }

  @override
  void onLoadDataSucceeded() {
    setState(() {
      isLoading = false;
    });
  }
}
