import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/pages/authentication/register/register_contract.dart';
import 'package:pcplus/pages/authentication/register/register_presenter.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/authentication/otp/OTP.dart';
import 'package:pcplus/pages/authentication/login/login.dart';

import '../../../component/register_component.dart';
import '../../widgets/profile/button_profile.dart';
import '../../widgets/profile/profile_input.dart';
import '../../widgets/util_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String routeName = 'register_screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> implements RegisterViewContract {
  RegisterPresenter? _registerPresenter;

  final emailController = TextEditingController();
  String? error;

  @override
  void initState() {
    _registerPresenter = RegisterPresenter(this);
    super.initState();
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
                'ĐĂNG KÝ',
                style: TextDecor.profileTitle,
              ),
              const Gap(30),
              ProfileInput(
                controller: emailController,
                icon: FontAwesomeIcons.user,
                hintText: 'Email',
                errorText: error,
              ),
              const Gap(35),
              ButtonProfile(
                name: 'Đăng ký',
                onPressed: () async {
                  await _registerPresenter!.register(emailController.text);
                },
              ),
              const Gap(20),
              Container(
                width: 280,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã có tài khoản?',
                      style: TextDecor.profileIntroText,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(LoginScreen.routeName);
                      },
                      child: Text(
                        'Đăng nhập',
                        style: TextDecor.profileTextButton,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onEmailAlreadyInUse() {
    setState(() {
      error = "Email đã được đăng ký";
    });
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onRegisterFailed() {
    UtilWidgets.createDismissibleDialog(
        context,
        UtilWidgets.NOTIFICATION,
        "Đã có lỗi xảy ra khi đăng ký tài khoản."
        " Hãy thử lại sau.",
        () {
          Navigator.of(context, rootNavigator: true).pop();
        }
    );
  }

  @override
  void onRegisterSucceeded(String email) {
    Navigator.of(context).pushNamed(
        OTPScreen.routeName,
        arguments: RegisterArgument(
          email: email,
          userModel: null,
          shopModel: null,
          userType: null,
        )
    );
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }
}
