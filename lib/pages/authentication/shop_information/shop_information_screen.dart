import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/component/register_component.dart';
import 'package:pcplus/config/asset_helper.dart';
import 'package:pcplus/const/shop_location.dart';
import 'package:pcplus/pages/authentication/shop_information/shop_information_contract.dart';
import 'package:pcplus/pages/authentication/shop_information/shop_information_presenter.dart';
import 'package:pcplus/pages/home/shop_home/shop_home.dart';
import 'package:pcplus/pages/widgets/profile/background_container.dart';
import 'package:pcplus/pages/widgets/profile/button_profile.dart';
import 'package:pcplus/pages/widgets/util_widgets.dart';
import 'package:pcplus/themes/text_decor.dart';

class ShopInformationScreen extends StatefulWidget {
  const ShopInformationScreen({super.key});
  static const String routeName = 'shop_information_screen';

  @override
  State<ShopInformationScreen> createState() => _ShopInformationScreenState();
}

class _ShopInformationScreenState extends State<ShopInformationScreen>
    implements ShopInformationContract {
  ShopInformationPresenter? _presenter;

  RegisterArgument? args;

  String _imageFile = "";

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<String> locations = LOCATIONS;

  @override
  void initState() {
    _presenter = ShopInformationPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    args = ModalRoute.of(context)!.settings.arguments as RegisterArgument;

    _presenter?.userModel = args?.userModel;
    _presenter?.password = args?.password;
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
      backgroundColor: Colors.white,
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
                'THÔNG TIN CỬA HÀNG',
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
                                image: AssetImage(AssetHelper.shopAvt),
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
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  style: TextDecor.robo16Medi,
                  controller: _shopNameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: Text(
                      'Tên cửa hàng',
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
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  readOnly: true,
                  onTap: _showLocationPicker,
                  controller: _locationController,
                  style: TextDecor.robo16Medi,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: Text(
                      'Địa chỉ',
                      style: TextDecor.profileHintText,
                    ),
                    hintStyle: TextDecor.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
              const Gap(30),
              ButtonProfile(
                name: 'HOÀN TẤT',
                onPressed: () {
                  _presenter?.handleConfirm(
                    name: _shopNameController.text.trim(),
                    location: _locationController.text.trim(),
                    phone: _phoneNumberController.text.trim(),
                  );
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
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
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
