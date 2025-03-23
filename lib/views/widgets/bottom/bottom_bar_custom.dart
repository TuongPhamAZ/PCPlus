import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/views/cart_shopping.dart';
import 'package:pcplus/views/home.dart';
import 'package:pcplus/views/notification.dart';
import 'package:pcplus/views/profile.dart';

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
            Navigator.of(context).pushNamed(HomeScreen.routeName);
          } else if (value == 1) {
            Navigator.of(context).pushNamed(CartShoppingScreen.routeName);
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
            icon: Icon(FontAwesomeIcons.cartShopping),
            label: 'Category',
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
