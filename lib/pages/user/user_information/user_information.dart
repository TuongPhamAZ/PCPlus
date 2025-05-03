import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/const/shop_location.dart';
import 'package:pcplus/pages/user/user_information/user_information_contract.dart';
import 'package:pcplus/pages/user/user_information/user_information_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';
import 'package:pcplus/pages/home/user_home/home.dart';
import 'package:pcplus/pages/home/shop_home/shop_home.dart';

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
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<String> locations = [];

  DateTime? _birthDate;

  @override
  void initState() {
    _presenter = UserInformationPresenter(this);
    _emailController.text = _presenter!.getEmail();
    super.initState();
  }

  void selectImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      _presenter!.pickedImage = pickedImage;
      setState(() {
        _imageFile = pickedImage.path;
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
                'Complete Your Profile',
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
                      'Full Name',
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
                      'Phone Number',
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
                      'Gender',
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
                              'Male',
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
                            Text('Female', style: TextDecor.robo16Medi),
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
                      'Birth Date',
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
                      'Password',
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
                      'Confirm Password',
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
                name: _isShopOwner ? 'NEXT' : 'DONE',
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
                      isSeller: _isShopOwner,
                      shopName: _shopNameController.text.trim(),
                      location: _locationController.text);
                },
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: LOCATIONS.map((location) {
            return ListTile(
              title: Text(location),
              onTap: () {
                setState(() {
                  _locationController.text = location;
                });
                Navigator.pop(context); // Đóng bottom sheet
              },
            );
          }).toList(),
        );
      },
    );
  }

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
  void onConfirmSucceeded() {
    Navigator.of(context).pushNamed(ShopHome.routeName);
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
