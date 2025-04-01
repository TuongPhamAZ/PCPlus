import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/notification/notification.dart';
import 'package:pcplus/pages/user/profile/profile.dart';
import 'package:pcplus/pages/home/shop_home/shop_home.dart';
import 'package:pcplus/pages/statistic/statistic.dart';

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
            Navigator.of(context).pushNamed(ShopHome.routeName);
          } else if (value == 1) {
            Navigator.of(context).pushNamed(Statistic.routeName);
          } else if (value == 2) {
            Navigator.of(context).pushNamed(NotificationScreen.routeName);
          } else if (value == 3) {
            Navigator.of(context).pushNamed(ProfileScreen.routeName);
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
            label: 'Statistic',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.bell),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidUser),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
