import 'dart:io';

import 'package:pcplus/contract/edit_profile_screen_contract.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/services/image_storage_service.dart';
import 'package:pcplus/services/pref_service.dart';
import 'package:pcplus/singleton/user_singleton.dart';

import '../models/users/user_model.dart';

class EditProfileScreenPresenter {
  final EditProfileScreenContract _view;
  EditProfileScreenPresenter(this._view);

  final UserRepository _userRepo = UserRepository();
  final PrefService _pref = PrefService();
  final ImageStorageService _imageStore = ImageStorageService();

  UserModel? user;
  File? avatarFile;

  Future<void> getData() async {
    user = await _pref.loadUserData();
    _view.onLoadDataSucceeded();
  }

  Future<void> handlePickAvatar() async {
    avatarFile = await _imageStore.pickImage();
    _view.onPickAvatar();
  }

  Future<void> handleSave({
    required String fullName,
    required String phone,
    required DateTime birthDate,
    required bool isMale,
  }) async {
    _view.onWaitingProgressBar();

    if (fullName.isEmpty || phone.isEmpty) {
      _view.onPopContext();
      _view.onSaveFailed("Please complete all required fields");
      return;
    }

    user!.name = fullName;
    user!.phone = phone;
    user!.dateOfBirth = birthDate;
    user!.gender = isMale ? "Male" : "Female";

    await _userRepo.updateUser(user!);
    await _pref.saveUserData(userData: user!);
    UserSingleton.getInstance().currentUser = user;
    _view.onPopContext();
    _view.onSaveSucceeded();
  }
}