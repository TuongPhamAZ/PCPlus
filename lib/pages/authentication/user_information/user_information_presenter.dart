import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/pages/authentication/user_information/user_information_contract.dart';
import 'package:pcplus/services/authentication_service.dart';
import 'package:pcplus/services/image_storage_service.dart';
import '../../../services/pref_service.dart';

class UserInformationPresenter {
  final UserInformationContract _view;
  UserInformationPresenter(this._view);

  final ImageStorageService _imageStorageService = ImageStorageService();
  final UserRepository _userRepo = UserRepository();
  final AuthenticationService _auth = AuthenticationService();

  PlatformFile? pickedImage;
  bool? isShop;

  List<String>? fcm;

  Future<void> getFcm() async {}

  Future<void> handleConfirm(
      {required String name,
      required String email,
      required String avatarUrl,
      required String phone,
      required bool isMale,
      required DateTime? birthDate,
      required String password,
      required String rePassword,
      required bool isSeller}) async {
    _view.onWaitingProgressBar();

    if (name.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        rePassword.isEmpty ||
        birthDate == null) {
      _view.onPopContext();
      _view.onConfirmFailed("Please complete all required fields");
      return;
    }

    // if (isSeller && (shopName.isEmpty || location.isEmpty)) {
    //   print("seller and shop name: $shopName");
    //   _view.onPopContext();
    //   _view.onConfirmFailed("Please complete all required fields");
    //   return;
    // }

    if (password.length < 8) {
      _view.onPopContext();
      _view.onConfirmFailed("Password must be equal or more than 8 characters");
      return;
    }

    if (password != rePassword) {
      _view.onPopContext();
      _view.onConfirmFailed("Passwords do not match");
      return;
    }

    try {
      UserCredential? userCredential =
          await _auth.signUpWithEmailAndPassword(email, password);
      if (userCredential == null) {
        _view.onPopContext();
        _view.onConfirmFailed("Something was wrong. Please try again.");
        return;
      }

      if (isShop!) {
        await userCredential.user?.delete();
      } else {
        await getFcm();
      }


      String? imagePath;

      if (pickedImage != null) {
        imagePath = await _imageStorageService.uploadImage(
          _imageStorageService.formatAvatarFolderName(), pickedImage!, userCredential.user!.uid);
        if (imagePath == null) {
          _view.onPopContext();
          _view.onConfirmFailed("Something was wrong. Please try again.");
          return;
        }
      }

      String avatarUrl =
          imagePath != null && imagePath.isNotEmpty ? imagePath : "";

      UserModel user = UserModel(
        userID: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        dateOfBirth: birthDate,
        gender: isMale ? "male" : "female",
        userType: UserType.USER,
        avatarUrl: avatarUrl,
      );

      if (isShop! == false) {
        await _userRepo.addUserToFirestore(user);
        await PrefService.saveUserData(userData: user, password: password);
        await FirebaseMessaging.instance.subscribeToTopic('${user.userID}');
        SessionController.getInstance().loadUser(user);
      }

      _view.onPopContext();
      _view.onConfirmSucceeded(user, password);
    } catch (e) {
      debugPrint(e.toString());
      _view.onPopContext();
      _view.onConfirmFailed("Something was wrong. Please try again.");
    }
  }
}
