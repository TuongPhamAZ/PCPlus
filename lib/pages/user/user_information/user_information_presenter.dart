import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/pages/user/user_information/user_information_contract.dart';
import 'package:pcplus/controller/api_controller.dart';
import 'package:pcplus/controller/register_controller.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/services/authentication_service.dart';
import 'package:pcplus/services/image_storage_service.dart';
import '../../../services/pref_service.dart';

class UserInformationPresenter {
  final UserInformationContract _view;
  UserInformationPresenter(this._view);

  final RegisterController _registerController =
      RegisterController.getInstance();
  // final ApiController _apiController = ApiController();
  // final PrefService _prefService = PrefService();
  final ImageStorageService _imageStorageService = ImageStorageService();
  final UserRepository _userRepo = UserRepository();
  final AuthenticationService _auth = AuthenticationService();

  XFile? pickedImage;

  String getEmail() {
    return _registerController.email!;
  }

  Future<void> handleConfirm(
      {required String name,
      required String email,
      required String avatarUrl,
      required String phone,
      required bool isMale,
      required DateTime? birthDate,
      required String password,
      required String rePassword,
      required bool isSeller,
      required String shopName,
      required String location}) async {
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

    if (isSeller && (shopName.isEmpty || location.isEmpty)) {
      print("seller and shop name: $shopName");
      _view.onPopContext();
      _view.onConfirmFailed("Please complete all required fields");
      return;
    }

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

    String? imagePath;

    if (pickedImage != null) {
      imagePath = await _imageStorageService.uploadImage(
          StorageFolderNames.AVATARS, File(pickedImage!.path));
      if (imagePath == null) {
        _view.onPopContext();
        _view.onConfirmFailed("Something was wrong. Please try again.");
        return;
      }
    }

    try {
      UserCredential? userCredential =
          await _auth.signUpWithEmailAndPassword(email, password);
      if (userCredential == null) {
        _view.onPopContext();
        _view.onConfirmFailed("Something was wrong. Please try again.");
        return;
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

      //await _apiController.callApiAddUserData(user);
      _registerController.user = user;

      await _userRepo.addUserToFirestore(user);
      await PrefService.saveUserData(userData: user, password: password);
      SessionController.getInstance().loadUser(user);
      _view.onPopContext();
      _view.onConfirmSucceeded();
    } catch (e) {
      print(e);
      _view.onPopContext();
      _view.onConfirmFailed("Something was wrong. Please try again.");
    }
  }
}
