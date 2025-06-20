import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/pages/user/edit_profile/edit_profile_screen_contract.dart';
import 'package:pcplus/pages/user/edit_profile/edit_profile_screen_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/user/change_password/change_password.dart';
import '../../../component/user_argument.dart';
import '../../../config/asset_helper.dart';
import '../../widgets/button/accept_button.dart';
import '../../widgets/button/cancel_button.dart';
import '../../widgets/profile/background_container.dart';
import '../../widgets/util_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  static const String routeName = 'edit_profile_screen';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> implements EditProfileScreenContract {
  EditProfileScreenPresenter? _presenter;

  String _userName = "";
  String _userAvatarUrl = "";
  String _email = "";
  bool _isMale = true;
  DateTime? _birthDate;
  bool isLoading = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  @override
  void initState() {
    _presenter = EditProfileScreenPresenter(this);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'THAY ĐỔI HỒ SƠ',
          style: TextDecor.profileTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: isLoading ? UtilWidgets.getLoadingWidget() : Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () async {
                    await _presenter!.handlePickAvatar();
                  },
                  child: Container(
                    height: 132,
                    width: 132,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: getAvatarImage(),
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
              Container(
                alignment: Alignment.center,
                child: Text(
                  _email,
                  style: TextDecor.robo16Medi
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
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    label: Text(
                      'Họ và tên',
                      style: TextDecor.profileHintText,
                    ),
                    hintStyle: TextDecor.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  style: TextDecor.robo16Medi,
                  keyboardType: TextInputType.number,
                  controller: _phoneController,
                  decoration: InputDecoration(
                    label: Text(
                      'Số điện thoại',
                      style: TextDecor.profileHintText,
                    ),
                    hintStyle: TextDecor.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
              BackgroundContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giới tính',
                      style: TextDecor.profileHintText.copyWith(
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              activeColor: Palette.main1,
                              side: const BorderSide(
                                width: 0.5,
                              ),
                              value: _isMale,
                              onChanged: (value) {
                                setState(() {
                                  _isMale = value!;
                                });
                              },
                            ),
                            Text(
                              'Nam',
                              style: TextDecor.robo16Medi,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              activeColor: Palette.main1,
                              side: const BorderSide(
                                width: 0.5,
                              ),
                              value: !_isMale,
                              onChanged: (value) {
                                setState(() {
                                  _isMale = !value!;
                                });
                              },
                            ),
                            Text('Nữ', style: TextDecor.robo16Medi),
                            const Gap(15),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  controller: _birthDateController,
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  style: TextDecor.robo16Medi,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _birthDate) {
                          setState(() {
                            _birthDate = picked;
                            _birthDateController.text =
                                '${picked.day}/${picked.month}/${picked.year}';
                          });
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.calendarDays),
                      color: Palette.hintText,
                    ),
                    label: Text(
                      'Ngày sinh',
                      style: TextDecor.profileHintText,
                    ),
                    hintStyle: TextDecor.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
              const Gap(15),
              AcceptButton(
                onPressed: () async {
                  await _presenter?.handleSave(
                      fullName: _fullNameController.text.trim(),
                      phone: _phoneController.text,
                      birthDate: _birthDate!,
                      isMale: _isMale
                  );
                },
                name: 'Lưu',
              ),
              const Gap(10),
              CancelButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Gap(20),
              Text(
                'Bạn có muốn thay đổi mật khẩu?',
                style: TextDecor.profileIntroText,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    ChangePasswordScreen.routeName,
                    arguments: UserArgument(user: _presenter!.user!),
                  );
                },
                child: Text(
                  'Đổi mật khẩu',
                  style: TextDecor.profileTextButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DecorationImage getAvatarImage() {
    if (_presenter != null && _presenter!.avatarFile != null) {
      return DecorationImage(
        image: FileImage(_presenter!.avatarFile!),
        fit: BoxFit.cover,
      );
    }

    if (_userAvatarUrl.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(_userAvatarUrl),
        fit: BoxFit.cover,
      );
    } else {
      return const DecorationImage(
        image: AssetImage(AssetHelper.defaultAvt),
        fit: BoxFit.cover,
      );
    }
  }

  @override
  void onLoadDataSucceeded() {
    setState(() {
      _userAvatarUrl = _presenter!.user!.avatarUrl!;
      _birthDate = _presenter!.user!.dateOfBirth;
      _email = _presenter!.user!.email!;
      _userName = _presenter!.user!.name!;
      _fullNameController.text = _presenter!.user!.name!;
      _isMale = _presenter!.user!.gender! == 'male';
      _phoneController.text = _presenter!.user!.phone!;
      _birthDateController.text = '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}';
      isLoading = false;
    });
  }

  @override
  void onSaveFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onSaveSucceeded() {
    setState(() {
      _birthDate = _presenter!.user!.dateOfBirth;
      _userName = _presenter!.user!.name!;
    });
    UtilWidgets.createSnackBar(context, "Lưu thành công!");
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
  void onPickAvatar() {
    setState(() {});
  }
}
