import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/notification/notification.dart';
import 'package:pcplus/pages/user/profile/profile.dart';
import 'package:pcplus/pages/home/shop_home/shop_home.dart';
import 'package:pcplus/pages/statistic/statistic.dart';

import '../../../services/nav_service.dart';

class ShopBottomBar extends StatelessWidget {
  final int currentIndex;
  const ShopBottomBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Palette.primaryColor,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (value) {
          if (value == 0) {
            NavService.pushNamedAndReplaceUntil(context, ShopHome.routeName);
          } else if (value == 1) {
            NavService.pushNamedAndReplaceUntil(context, Statistic.routeName);
          } else if (value == 2) {
            NavService.pushNamedAndReplaceUntil(context, NotificationScreen.routeName);
          } else if (value == 3) {
            NavService.pushNamedAndReplaceUntil(context, ProfileScreen.routeName);
          } else {}
        },
        selectedItemColor: Palette.primaryColor,
        unselectedItemColor: Palette.bottomBarUnSelect,
        selectedLabelStyle: TextDecor.bottomLableSelect,
        unselectedLabelStyle: TextDecor.bottomLableSelect,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.bell),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidUser),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
