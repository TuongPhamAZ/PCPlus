import 'dart:io';

import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/pages/user/edit_profile/edit_profile_screen_contract.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/services/image_storage_service.dart';
import 'package:pcplus/services/pref_service.dart';

import '../../../models/users/user_model.dart';

class EditProfileScreenPresenter {
  final EditProfileScreenContract _view;
  EditProfileScreenPresenter(this._view);

  final UserRepository _userRepo = UserRepository();
  final ImageStorageService _imageStore = ImageStorageService();

  UserModel? user;
  File? avatarFile;
  bool _isDisposed = false;

  Future<void> getData() async {
    if (_isDisposed) return;

    user = SessionController.getInstance().currentUser;
    _view.onLoadDataSucceeded();
  }

  Future<void> handlePickAvatar() async {
    if (_isDisposed) return;

    avatarFile = await _imageStore.pickImage();
    _view.onPickAvatar();
  }

  Future<void> handleSave({
    required String fullName,
    required String phone,
    required DateTime birthDate,
    required bool isMale,
  }) async {
    if (_isDisposed) return;

    _view.onWaitingProgressBar();

    if (fullName.isEmpty || phone.isEmpty) {
      _view.onPopContext();
      _view.onSaveFailed("Vui lòng điền đầy đủ thông tin");
      return;
    }

    user!.name = fullName;
    user!.phone = phone;
    user!.dateOfBirth = birthDate;
    user!.gender = isMale ? "Male" : "Female";

    await _userRepo.updateUser(user!);
    await PrefService.saveUserData(userData: user!);

    _view.onPopContext();
    _view.onSaveSucceeded();
  }

  Future<void> dispose() async {
    _isDisposed = true;
    // Cleanup any resources if needed in future
  }
}
