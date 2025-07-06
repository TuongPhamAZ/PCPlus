import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/pages/authentication/shop_information/shop_information_screen.dart';
import 'package:pcplus/pages/authentication/user_information/user_information_contract.dart';
import 'package:pcplus/pages/authentication/user_information/user_information_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../../component/register_component.dart';
import '../../../models/users/user_model.dart';
import '../../home/user_home/home.dart';
import '../../widgets/profile/background_container.dart';
import '../../widgets/profile/button_profile.dart';
import '../../widgets/util_widgets.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});
  static const String routeName = 'user_information';

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation>
    implements UserInformationContract {
  UserInformationPresenter? _presenter;

  RegisterArgument? args;

  String _imageFile = "";

  bool _isMale = true;
  bool _passwordVisible = false;
  bool _rePasswordVisible = false;
  bool _isShopOwner = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  DateTime? _birthDate;

  @override
  void initState() {
    _presenter = UserInformationPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    args = ModalRoute.of(context)!.settings.arguments as RegisterArgument;

    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      _emailController.text = args!.email!;
      _presenter?.isShop = args!.userType == UserType.SHOP;
      _isShopOwner = _presenter!.isShop!;
    });
  }

  void selectImageFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // cần thiết để lấy bytes
    );
    if (result != null) {
      _presenter!.pickedImage = result.files.first;
      setState(() {
        _imageFile = result.files.first.path!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: size.width,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(30),
              Text(
                'Thông tin cá nhân',
                style: TextDecor.profileTitle,
              ),
              const Gap(10),
              Stack(
                children: [
                  GestureDetector(
                    onTap: selectImageFromGallery,
                    child: Container(
                      width: 92.0,
                      height: 92.0,
                      decoration: _imageFile.isEmpty
                          ? const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(AssetHelper.defaultAvt),
                                fit: BoxFit.cover,
                              ),
                            )
                          : BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: FileImage(File(_imageFile)),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: -12.0,
                    right: -12.0,
                    child: IconButton(
                      onPressed: selectImageFromGallery,
                      icon: const Icon(Icons.camera_alt),
                      color: const Color.fromARGB(255, 244, 54, 212),
                    ),
                  ),
                ],
              ),
              const Gap(30),
              BackgroundContainer(
                alignment: Alignment.center,
                child: TextField(
                  readOnly: true,
                  controller: _emailController,
                  style: TextDecor.robo16Medi,
                  decoration: InputDecoration(
                    label: Text(
                      'Email',
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
                  controller: _fullNameController,
                  keyboardType: TextInputType.text,
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
                  controller: _phoneNumberController,
                  style: TextDecor.robo16Medi,
                  keyboardType: TextInputType.number,
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
                                  _isMale = value!;
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
                  readOnly: true,
                  onTap: _datePicker,
                  style: TextDecor.robo16Medi,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: _datePicker,
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
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  style: TextDecor.robo16Medi,
                  keyboardType: TextInputType.text,
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    label: Text(
                      'Mật khẩu',
                      style: TextDecor.profileHintText,
                    ),
                    hintStyle: TextDecor.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      icon: Icon(
                        _passwordVisible
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
                  controller: _rePasswordController,
                  keyboardType: TextInputType.text,
                  obscureText: !_rePasswordVisible,
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
              const Gap(20),
              ButtonProfile(
                name: _isShopOwner ? 'TIẾP TỤC' : 'HOÀN TẤT',
                onPressed: () {
                  _presenter!.handleConfirm(
                      name: _fullNameController.text.trim(),
                      email: _emailController.text.trim(),
                      avatarUrl: _imageFile,
                      phone: _phoneNumberController.text.trim(),
                      isMale: _isMale,
                      birthDate: _birthDate,
                      password: _passwordController.text.trim(),
                      rePassword: _rePasswordController.text.trim(),
                      isSeller: _isShopOwner);
                  // shopName: _shopNameController.text.trim(),
                  // location: _locationController.text);
                },
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }

  // void _showLocationPicker() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return ListView(
  //         children: LOCATIONS.map((location) {
  //           return ListTile(
  //             title: Text(location),
  //             onTap: () {
  //               setState(() {
  //                 _locationController.text = location;
  //               });
  //               Navigator.pop(context); // Đóng bottom sheet
  //             },
  //           );
  //         }).toList(),
  //       );
  //     },
  //   );
  // }

  Future<void> _datePicker() async {
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
  }

  @override
  void onConfirmFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onConfirmSucceeded(UserModel userModel, String password) {
    if (_isShopOwner) {
      args?.userModel = userModel;
      args?.password = password;
      Navigator.of(context).pushNamed(
        ShopInformationScreen.routeName,
        arguments: args,
      );
    } else {
      Navigator.of(context).pushNamed(HomeScreen.routeName);
    }
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
