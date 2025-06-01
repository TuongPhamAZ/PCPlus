import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/const/order_status.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/pages/user/profile/profile_screen_contract.dart';
import 'package:pcplus/pages/user/profile/profile_screen_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/user/edit_profile/edit_profile.dart';
import 'package:pcplus/pages/authentication/login/login.dart';
import 'package:pcplus/pages/rating/rating.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../history_order/history_order.dart';
import '../../widgets/bottom/bottom_bar_custom.dart';
import '../../widgets/bottom/shop_bottom_bar.dart';
import '../../widgets/profile/background_container.dart';
import '../../widgets/util_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String routeName = 'profile_screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    implements ProfileScreenContract {
  ProfileScreenPresenter? _presenter;
  String _userAvatarUrl = "";
  String _userName = "";
  bool _isLoading = true;
  bool isShop = false;

  int awaitConfirm = 0;
  int awaitPickUp = 0;
  int awaitDelivery = 0;
  int awaitRating = 0;

  Future<void> launchEmailApp() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'personalschedulemanager@gmail.com',
      queryParameters: {
        'subject': 'Góp_Ý_Của_Người_Dùng',
      },
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Lỗi'),
              content: const Text('Thiết bị của bạn không có ứng dụng email!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                )
              ],
            );
          });
    }
  }

  Future<void> showNotificationDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade100,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Palette.primaryColor,
                    size: 30,
                  ),
                ),
                const Gap(20),
                Text(
                  'Thông báo',
                  style: TextDecor.profileName.copyWith(
                    fontSize: 20,
                    color: Palette.primaryColor,
                  ),
                ),
                const Gap(15),
                Text(
                  'Bạn có muốn tiếp tục nhận thông báo từ tài khoản này không?',
                  textAlign: TextAlign.center,
                  style: TextDecor.profileIntroText.copyWith(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const Gap(25),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Thực hiện unsubtopic trước khi đăng xuất
                            unsubtopic();
                            _presenter!.signOut();
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Không',
                            style: TextDecor.profileTextButton.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: const LinearGradient(
                            colors: [
                              Palette.primaryColor,
                              Palette.main1,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Palette.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Chỉ đăng xuất bình thường
                            _presenter!.signOut();
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Có',
                            style: TextDecor.profileTextButton.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> unsubtopic() async {
    await _presenter?.unsubtopic();
  }

  Future<void> showSignOutDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade100,
                  ),
                  child: const Icon(
                    FontAwesomeIcons.rightFromBracket,
                    color: Colors.red,
                    size: 35,
                  ),
                ),
                const Gap(20),
                Text(
                  'Xác nhận đăng xuất',
                  style: TextDecor.profileName.copyWith(
                    fontSize: 22,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(15),
                Text(
                  'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?',
                  textAlign: TextAlign.center,
                  style: TextDecor.profileIntroText.copyWith(
                    fontSize: 16,
                    height: 1.4,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Gap(30),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Hủy',
                            style: TextDecor.profileTextButton.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(15),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Hiển thị dialog thông báo
                            showNotificationDialog();
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Xác nhận',
                            style: TextDecor.profileTextButton.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _presenter = ProfileScreenPresenter(this);
    isShop = SessionController.getInstance().isShop();

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'PROFILE',
          style: TextDecor.profileTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: _isLoading
            ? UtilWidgets.getLoadingWidget()
            : Container(
                height: size.height - 140,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetHelper.profileBg),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(20),
                    Container(
                      alignment: Alignment.center,
                      child: Container(
                        height: 132,
                        width: 132,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: _userAvatarUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_userAvatarUrl),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage(AssetHelper.defaultAvt),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        _userName,
                        style: TextDecor.profileName,
                      ),
                    ),
                    const Gap(25),
                    BackgroundContainer(
                      horizontalPadding: 20,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đơn hàng',
                                style: TextDecor.profileIntroText,
                              ),
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HistoryOrder(
                                        orderType: "",
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Xem lịch sử đơn hàng',
                                  style: TextDecor.profileIntroText.copyWith(
                                    color: Palette.main1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Gap(10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HistoryOrder(
                                        orderType:
                                            OrderStatus.PENDING_CONFIRMATION,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Stack(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                top: 5, right: 6),
                                            child: Icon(
                                              FontAwesomeIcons.wallet,
                                              size: 30,
                                              color: Palette.main1,
                                            ),
                                          ),
                                          awaitConfirm > 0
                                              ? Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          Palette.primaryColor,
                                                    ),
                                                    child: Text(
                                                      '$awaitConfirm',
                                                      style: TextDecor.robo16
                                                          .copyWith(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    const Gap(3),
                                    Text(
                                      'Chờ xác nhận',
                                      style: TextDecor.orderProfile,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isShop)
                                InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HistoryOrder(
                                          orderType: OrderStatus.AWAIT_PICKUP,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Stack(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 5, right: 6),
                                              child: Icon(
                                                FontAwesomeIcons.boxesPacking,
                                                size: 30,
                                                color: Palette.main1,
                                              ),
                                            ),
                                            awaitPickUp > 0
                                                ? Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Palette
                                                            .primaryColor,
                                                      ),
                                                      child: Text(
                                                        '$awaitPickUp',
                                                        style: TextDecor.robo16
                                                            .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                      const Gap(3),
                                      Text(
                                        'Chờ lấy hàng',
                                        style: TextDecor.orderProfile,
                                      ),
                                    ],
                                  ),
                                ),
                              InkWell(
                                onTap: () async {
                                  if (isShop) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HistoryOrder(
                                          orderType: OrderStatus.AWAIT_PICKUP,
                                        ),
                                      ),
                                    );
                                  } else {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HistoryOrder(
                                          orderType: OrderStatus.AWAIT_DELIVERY,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Stack(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                top: 5, right: 3),
                                            child: Icon(
                                              FontAwesomeIcons.truck,
                                              size: 30,
                                              color: Palette.main1,
                                            ),
                                          ),
                                          (isShop
                                                  ? awaitPickUp > 0
                                                  : awaitDelivery > 0)
                                              ? Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          Palette.primaryColor,
                                                    ),
                                                    child: Text(
                                                      '${isShop ? awaitPickUp : awaitDelivery}',
                                                      style: TextDecor.robo16
                                                          .copyWith(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                    const Gap(3),
                                    Text(
                                      isShop ? 'Chờ gửi hàng' : 'Chờ giao hàng',
                                      style: TextDecor.orderProfile,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isShop)
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed(RatingScreen.routeName);
                                  },
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Stack(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 5, right: 3),
                                              child: Icon(
                                                FontAwesomeIcons.rankingStar,
                                                size: 30,
                                                color: Palette.main1,
                                              ),
                                            ),
                                            awaitRating > 0
                                                ? Positioned(
                                                    right: 0,
                                                    top: 0,
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Palette
                                                            .primaryColor,
                                                      ),
                                                      child: Text(
                                                        '$awaitRating',
                                                        style: TextDecor.robo16
                                                            .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                      const Gap(3),
                                      Text(
                                        'Đánh giá',
                                        style: TextDecor.orderProfile,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          const Gap(20),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(EditProfileScreen.routeName);
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    FontAwesomeIcons.user,
                                    color: Palette.primaryColor,
                                    size: 25,
                                  ),
                                ),
                                Text(
                                  'Edit Profile',
                                  style: TextDecor.profileTextButton,
                                ),
                              ],
                            ),
                          ),
                          const Gap(20),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    FontAwesomeIcons.language,
                                    color: Palette.primaryColor,
                                    size: 25,
                                  ),
                                ),
                                Text(
                                  'Change Language',
                                  style: TextDecor.profileTextButton,
                                ),
                              ],
                            ),
                          ),
                          const Gap(20),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.add_alert_rounded,
                                    color: Palette.primaryColor,
                                    size: 30,
                                  ),
                                ),
                                Text(
                                  'Notification Setting',
                                  style: TextDecor.profileTextButton,
                                ),
                              ],
                            ),
                          ),
                          const Gap(20),
                          GestureDetector(
                            onTap: () {
                              launchEmailApp();
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    FontAwesomeIcons.solidCircleQuestion,
                                    color: Palette.primaryColor,
                                    size: 25,
                                  ),
                                ),
                                Text(
                                  'Help Center',
                                  style: TextDecor.profileTextButton,
                                ),
                              ],
                            ),
                          ),
                          const Gap(20),
                          GestureDetector(
                            onTap: () async {
                              showSignOutDialog();
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    // ignore: deprecated_member_use
                                    FontAwesomeIcons.signOut,
                                    color: Palette.primaryColor,
                                    size: 25,
                                  ),
                                ),
                                Text(
                                  'Sign Out',
                                  style: TextDecor.profileTextButton,
                                ),
                              ],
                            ),
                          ),
                          const Gap(20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: isShop
          ? const ShopBottomBar(currentIndex: 3)
          : const BottomBarCustom(currentIndex: 3),
    );
  }

  @override
  void onLoadDataSucceeded() {
    if (!mounted) return;

    setState(() {
      _userName = _presenter!.user!.name!;
      _userAvatarUrl = _presenter!.user!.avatarUrl!;
      _isLoading = false;
    });
  }

  @override
  void onSignOut() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      LoginScreen.routeName,
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
  void onUpdateOrdersCount() {
    if (!mounted) return;

    setState(() {
      awaitDelivery = _presenter!.awaitDelivery;
      awaitConfirm = _presenter!.awaitConfirm;
      awaitPickUp = _presenter!.awaitPickup;
      awaitRating = _presenter!.awaitRating;
    });
  }

  @override
  void onUnsubtopicSucceeded() {}

  @override
  void onUnsubtopicFailed(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi khi hủy đăng ký thông báo: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
