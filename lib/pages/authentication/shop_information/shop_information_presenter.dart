import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/models/shops/shop_repo.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/pages/authentication/shop_information/shop_information_contract.dart';

import '../../../controller/session_controller.dart';
import '../../../models/shops/shop_model.dart';
import '../../../models/users/user_repo.dart';
import '../../../services/authentication_service.dart';
import '../../../services/image_storage_service.dart';
import '../../../services/pref_service.dart';

class ShopInformationPresenter {
  final ShopInformationContract _view;
  ShopInformationPresenter(this._view);

  final ImageStorageService _imageStorageService = ImageStorageService();
  final UserRepository _userRepo = UserRepository();
  final ShopRepository _shopRepo = ShopRepository();
  final AuthenticationService _auth = AuthenticationService();
  PlatformFile? pickedImage;

  UserModel? userModel;
  String? password;

  List<String>? fcm;

  Future<void> handleConfirm({
    required String name,
    required String location,
    required String phone,
  }) async {
    _view.onWaitingProgressBar();

    if (name.isEmpty || phone.isEmpty) {
      _view.onPopContext();
      _view.onConfirmFailed("Please complete all required fields");
      return;
    }

    try {
      UserCredential? userCredential =
          await _auth.signUpWithEmailAndPassword(userModel!.email!, password!);
      if (userCredential == null) {
        _view.onPopContext();
        _view.onConfirmFailed("Something was wrong. Please try again.");
        return;
      }

      userModel!.userID = userCredential.user!.uid;
      userModel!.userType = UserType.SHOP;

      // Rename avatar
      String userAvatarPath = await _imageStorageService.renameCloudinaryImage(
          fromPublicPath: userModel!.avatarUrl!,
          toPublicId: "${_imageStorageService.formatAvatarFolderName()}/${userModel!.userID!}"
      );

      userModel!.avatarUrl = userAvatarPath;

      String? imagePath;

      if (pickedImage != null) {
        imagePath = await _imageStorageService.uploadImage(
            _imageStorageService.formatShopFolderName(userModel!.userID!),
            pickedImage!,
            "${userModel!.userID}"
        );
        if (imagePath == null) {
          _view.onPopContext();
          _view.onConfirmFailed("Something was wrong. Please try again.");
          return;
        }
      }

      String avatarUrl = imagePath != null && imagePath.isNotEmpty ? imagePath : "";

      ShopModel shopModel = ShopModel(
        shopID: userCredential.user!.uid,
        name: name,
        phone: phone,
        rating: 0,
        location: location,
        image: avatarUrl,
      );

      await _userRepo.addUserToFirestore(userModel!);
      await PrefService.saveUserData(userData: userModel!, password: password);
      SessionController.getInstance().loadUser(userModel!);

      await _shopRepo.addShopToFirestore(shopModel);
      await PrefService.saveShopData(shopData: shopModel);
      await SessionController.getInstance().loadUser(userModel!);

      await FirebaseMessaging.instance.subscribeToTopic('${userModel!.userID}');

      _view.onPopContext();
      _view.onConfirmSucceeded();
    } catch (e) {
      debugPrint(e as String?);
      _view.onPopContext();
      _view.onConfirmFailed("Something was wrong. Please try again.");
    }
  }
}
