import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/services/authentication_service.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/pages/home/user_home/home.dart';
import 'package:pcplus/pages/authentication/login/login.dart';
import 'package:pcplus/pages/home/shop_home/shop_home.dart';

import '../../services/test_tool.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = 'splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthenticationService _auth = AuthenticationService();
  AnimationController? _controller;
  Animation<double>? _animation;

  bool loginSucceeded = false;

  @override
  void initState() {
    super.initState();
    _getUserData();

    // Tạo AnimationController với thời gian 3 giây
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Sử dụng Tween để tạo giá trị tiến trình từ 0 đến 1
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller!)
      ..addListener(() {
        setState(() {}); // Cập nhật UI khi giá trị tiến trình thay đổi
      });

    // Bắt đầu animation
    _controller!.forward().then((_) {
      _navigateToHome();
    });
  }

  Future<void> _getUserData() async {
    // TestTool testTool = TestTool();
    // await testTool.createSampleItems();
    // await testTool.createSampleUsers();
    // await testTool.createRandomInteractions();
    // return;

    UserModel? loggedUser = await PrefService.loadUserData();
    if (loggedUser == null) {
      return;
    }

    String password = await PrefService.getPassword();
    UserCredential? userCredential =
        await _auth.signInWithEmailAndPassword(loggedUser.email!, password, AuthResult());

    if (userCredential != null) {

      final UserRepository userRepo = UserRepository();

      UserModel? userData = await userRepo.getUserById(userCredential.user!.uid);

      loginSucceeded = true;
      await SessionController.getInstance().loadUser(userData!);
    }
  }

  // Hàm chuyển sang màn hình Login
  void _navigateToHome() {
    if (loginSucceeded) {
      if (SessionController.getInstance().isShop()) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          ShopHome.routeName,
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          HomeScreen.routeName,
          (Route<dynamic> route) => false,
        );
      }
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Hủy AnimationController khi không cần nữa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.7,
              height: size.width * 0.7,
              child: Image.asset(AssetHelper.logo),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: LinearProgressIndicator(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                minHeight: 18,
                value: _animation?.value, // Giá trị tiến trình từ Animation
                backgroundColor: Palette.greyBackground,
                valueColor: const AlwaysStoppedAnimation<Color>(Palette.main1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
