import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/cart/cart_shopping.dart';
import 'package:pcplus/pages/home/user_home/home.dart';
import 'package:pcplus/pages/notification/notification.dart';
import 'package:pcplus/pages/user/profile/profile.dart';

import '../../../services/nav_service.dart';

class BottomBarCustom extends StatelessWidget {
  final int currentIndex;
  const BottomBarCustom({super.key, required this.currentIndex});

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
            NavService.pushNamedAndReplaceUntil(context, HomeScreen.routeName);
          } else if (value == 1) {
            NavService.pushNamedAndReplaceUntil(context, CartShoppingScreen.routeName);
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
            icon: Icon(FontAwesomeIcons.cartShopping),
            label: 'Giỏ hàng',
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
