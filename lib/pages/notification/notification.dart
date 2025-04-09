import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcplus/pages/notification/notification_screen_contract.dart';
import 'package:pcplus/models/notification/notification_model.dart';
import 'package:pcplus/pages/notification/notification_screen_presenter.dart';
import 'package:pcplus/singleton/user_singleton.dart';
import 'package:pcplus/themes/palette/palette.dart';
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

class _NotificationScreenState extends State<NotificationScreen> implements NotificationScreenContract {
  NotificationScreenPresenter? _presenter;

  bool isShop = false;
  bool isLoading = true;

  @override
  void initState() {
    _presenter = NotificationScreenPresenter(this);
    isShop = UserSingleton.getInstance().isShop();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    await _presenter?.getData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.0),
        ),
        child:
        StreamBuilder<List<NotificationModel>>(
            stream: _presenter!.notificationStream,
            builder: (context, snapshot) {
              Widget? result = UtilWidgets.createSnapshotResultWidget(context, snapshot);
              if (result != null) {
                return result;
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return const Center(child: Text('No data'));
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
                  );
                },
              );
            }
        ),
      ),
      bottomNavigationBar: isShop ? const ShopBottomBar(currentIndex: 2) : const BottomBarCustom(currentIndex: 2),
    );
  }

  @override
  void onLoadDataSucceeded() {
    setState(() {
      isLoading = false;
    });
  }
}
