import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../widgets/profile/button_profile.dart';

class NoNetworkScreen extends StatefulWidget {
  const NoNetworkScreen({super.key});
  static const String routeName = 'no_network_screen';

  @override
  State<NoNetworkScreen> createState() => _NoNetworkScreenState();
}

class _NoNetworkScreenState extends State<NoNetworkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetHelper.noNetwork,
              width: 325,
              height: 260,
            ),
            Text(
              'Không có kết nối',
              style: TextDecor.noInternetTitle,
            ),
            const Gap(12),
            Text(
              'Ups. Bạn chưa kết nối Internet.\nHãy thử lại sau.',
              textAlign: TextAlign.center,
              style: TextDecor.noInternetDes,
            ),
            const Gap(30),
            ButtonProfile(
              name: 'Thử lại',
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
