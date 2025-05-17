import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/component/register_component.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/pages/authentication/account_type/account_type_contract.dart';
import 'package:pcplus/pages/authentication/account_type/account_type_presenter.dart';
import 'package:pcplus/pages/widgets/profile/button_profile.dart';
import 'package:pcplus/pages/widgets/util_widgets.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../../models/users/user_model.dart';
import '../shop_information/shop_information_screen.dart';
import '../user_information/user_information.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});
  static const String routeName = 'account_type_screen';

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen>
    implements AccountTypeContract {
  AccountTypePresenter? _accountTypePresenter;

  RegisterArgument? args;

  @override
  void initState() {
    _accountTypePresenter = AccountTypePresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    args = ModalRoute.of(context)!.settings.arguments as RegisterArgument;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(50),
              Image.asset(
                AssetHelper.logo,
                width: 150,
                height: 150,
              ),
              const Gap(20),
              Text(
                'ACCOUNT TYPE?',
                style: TextDecor.profileTitle,
              ),
              const Gap(85),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 50),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: Palette.main3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  _accountTypePresenter?.onSelectAccountType(UserType.SHOP);
                },
                child: Text(
                  "SHOP OWNER",
                  style:
                      TextDecor.noInternetTitle.copyWith(color: Colors.white),
                ),
              ),
              const Gap(20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 50),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Palette.main3, width: 2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  _accountTypePresenter?.onSelectAccountType(UserType.USER);
                },
                child: Text(
                  "CUSTOMER",
                  style:
                      TextDecor.noInternetTitle.copyWith(color: Palette.main3),
                ),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onSelectUserType(String userType) {
    // TODO: implement onSelectUserType
    args?.userType = userType;
    Navigator.of(context).pushNamed(
        UserInformation.routeName,
        arguments: args,
    );
  }
}
