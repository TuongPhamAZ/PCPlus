import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/pages/authentication/login/login_contract.dart';
import 'package:pcplus/pages/home/shop_home/shop_home.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/pages/authentication/forgot_password/forgot_password.dart';
import 'package:pcplus/pages/authentication/register/register.dart';
import '../../widgets/profile/button_profile.dart';
import '../../widgets/profile/profile_input.dart';
import '../../widgets/util_widgets.dart';
import 'login_presenter.dart';
import '../../home/user_home/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements LoginViewContract {
  LoginPresenter? _loginPresenter;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  BuildContext? progressbarContext;
  String? error;

  @override
  void initState() {
    _loginPresenter = LoginPresenter(this);
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
                'ĐĂNG NHẬP',
                style: TextDecor.profileTitle,
              ),
              const Gap(30),
              ProfileInput(
                controller: emailController,
                icon: FontAwesomeIcons.user,
                hintText: 'Tài khoản',
                errorText: error,
              ),
              const Gap(20),
              ProfileInput(
                controller: passwordController,
                icon: Icons.lock_outline_rounded,
                hintText: 'Mật khẩu',
                obscureText: true,
                errorText: error,
              ),
              const Gap(35),
              ButtonProfile(
                name: 'Đăng nhập',
                onPressed: () async {
                  await _loginPresenter!.login(emailController.text, passwordController.text);
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
                      'Chưa có tài khoản? ',
                      style: TextDecor.profileIntroText,
                    ),
                    InkWell(
                      onTap: () {
                        onRegister();
                      },
                      child: Text(
                        'Đăng ký',
                        style: TextDecor.profileTextButton,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(5),
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(ForgotPasswordScreen.routeName);
                },
                child: Container(
                  width: 280,
                  alignment: Alignment.center,
                  child: Text(
                    'Quên mật khẩu',
                    style: TextDecor.profileTextButton
                        .copyWith(color: Palette.main1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onRegister() {
    Navigator.of(context).pushNamed(RegisterScreen.routeName);
  }

  @override
  void onLoginFailed() {
    setState(() {
      error = "Email hoặc mật khẩu không chính xác";
    });
  }

  @override
  void onLoginSucceeded() {
    // TODO: implement onLoginSucceeded
    Navigator.of(context).pushNamedAndRemoveUntil(
      SessionController.getInstance().isShop() ? ShopHome.routeName : HomeScreen.routeName,
      (Route<dynamic> route) => false,
    );
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  @override
  void onError(String message) {
    UtilWidgets.createSnackBar(context, message);
    setState(() {
      error = "";
    });
  }
}
