import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/pages/user/change_password/change_password_contract.dart';
import 'package:pcplus/pages/user/change_password/change_password_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import '../../../component/user_argument.dart';
import '../../../models/users/user_model.dart';
import '../../widgets/button/accept_button.dart';
import '../../widgets/button/cancel_button.dart';
import '../../widgets/profile/background_container.dart';
import '../../widgets/util_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  static const String routeName = 'change_password_screen';

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> implements ChangePasswordContract {
  ChangePasswordPresenter? _presenter;
  UserModel? user;
  String _userAvatarUrl = "";

  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _rePasswordVisible = false;

  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _rePassController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy arguments từ route
    final args = ModalRoute.of(context)?.settings.arguments as UserArgument?;
    user = args?.user;
    _userAvatarUrl = user!.avatarUrl ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ĐỔI MẬT KHẨU",
          style: TextDecor.profileTitle.copyWith(fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
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
                  user!.name!,
                  style: TextDecor.profileName,
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  user!.email!,
                  style: TextDecor.robo16Medi,
                ),
              ),
              const Gap(20),
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  style: TextDecor.robo16Medi,
                  keyboardType: TextInputType.text,
                  obscureText: !_oldPasswordVisible,
                  controller: _oldPassController,
                  decoration: InputDecoration(
                    label: Text(
                      'Mật khẩu cũ',
                      style: TextDecor.profileHintText,
                    ),
                    hintStyle: TextDecor.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _oldPasswordVisible = !_oldPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _oldPasswordVisible
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        color: Palette.hintText,
                        size: 18,
                      ),
                      color: Palette.hintText,
                    ),
                  ),
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _newPassController,
                  style: TextDecor.robo16Medi,
                  keyboardType: TextInputType.text,
                  obscureText: !_newPasswordVisible,
                  decoration: InputDecoration(
                    label: Text(
                      'Mật khẩu mới',
                      style: TextDecor.profileHintText,
                    ),
                    hintStyle: TextDecor.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _newPasswordVisible = !_newPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _newPasswordVisible
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        color: Palette.hintText,
                        size: 18,
                      ),
                      color: Palette.hintText,
                    ),
                  ),
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  style: TextDecor.robo16Medi,
                  keyboardType: TextInputType.text,
                  obscureText: !_rePasswordVisible,
                  controller: _rePassController,
                  decoration: InputDecoration(
                    label: Text(
                      'Xác nhận mật khẩu',
                      style: TextDecor.profileHintText,
                    ),
                    hintStyle: TextDecor.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _rePasswordVisible = !_rePasswordVisible;
                        });
                      },
                      icon: Icon(
                        _rePasswordVisible
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        color: Palette.hintText,
                        size: 18,
                      ),
                      color: Palette.hintText,
                    ),
                  ),
                ),
              ),
              const Gap(15),
              AcceptButton(
                onPressed: () {
                  _presenter?.handleChange(
                      oldPass: _oldPassController.text,
                      newPass: _newPassController.text,
                      rePass: _rePassController.text,
                  );
                },
                name: 'ĐỔI MẬT KHẨU',
              ),
              const Gap(10),
              CancelButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onChangeSucceeded() {
    UtilWidgets.createDialog(
        context,
        UtilWidgets.NOTIFICATION,
        "Đổi mật khẩu thành công",
        () {
          Navigator.of(context, rootNavigator: true).pop();
        }
    );
    setState(() {
      _rePassController.clear();
      _newPassController.clear();
      _oldPassController.clear();
    });
  }

  @override
  void onChangedFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }
}
