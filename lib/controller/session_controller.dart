
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pcplus/models/shops/shop_repo.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/pages/widgets/util_widgets.dart';
import 'package:pcplus/services/nav_service.dart';
import 'package:pcplus/services/pref_service.dart';

import '../models/interactions/interaction_model.dart';
import '../models/interactions/interaction_repo.dart';
import '../models/shops/shop_model.dart';
import '../models/users/user_model.dart';
import '../pages/authentication/login/login.dart';

class SessionController {
  static SessionController? _instance;
  static SessionController getInstance() {
    _instance ??= SessionController();
    return _instance!;
  }

  String? userID;
  String? currentFcm;
  bool isSeller = false;

  bool firstEnter = false;

  final ShopRepository _shopRepository = ShopRepository();
  final UserRepository _userRepository = UserRepository();

  Stream<UserModel?>? userStream;
  StreamSubscription<UserModel?>? _userSubscription;
  UserModel? currentUser;

  Future<void> loadUser(UserModel user) async {
    userID = user.userID;
    firstEnter = true;
    currentFcm = user.activeFcm;

    isSeller = user.userType == UserType.SHOP;

    if (isSeller) {
      ShopModel shop = await _shopRepository.getShopById(userID!);
      await PrefService.saveShopData(shopData: shop);
    }

    userStream = _userRepository.getUserByIdStream(userID!);
    listenToUserStream();
  }

  Future<void> signOut() async {
    await PrefService.clearUserData();
    await PrefService.clearShopData();
    cancelUserStream();
  }

  bool isShop() {
    return isSeller;
  }

  // STREAM
  void listenToUserStream() {
    _userSubscription = userStream!.listen((user) {
      currentUser = user;
      onUserModelChange();
    });
  }

  void cancelUserStream() {
    _userSubscription?.cancel();
    _userSubscription = null;
    userStream = null;
    currentUser = null;
  }

  void onUserModelChange() {
    if (currentFcm != currentUser!.activeFcm) {
      NavService.nav!.pushNamedAndRemoveUntil(
        LoginScreen.routeName,
            (Route<dynamic> route) => false,
      );
      UtilWidgets.createDialog(
          NavService.context!,
          "Thông báo",
          "Tài khoản của bạn đã được đăng nhập trên thiết bị khác.",
          () => {}
      );
    }
  }

  // INTERACTION

  Future<InteractionModel> getInteractionModel(String itemID) async {
    InteractionRepository interactionRepo = InteractionRepository();

    InteractionModel? model = await interactionRepo.getInteractionByUserIDAndItemID(userID!, itemID);

    if (model == null) {
      model = InteractionModel(
          userID: userID,
          itemID: itemID,
          clickTimes: 0,
          buyTimes: 0,
          rating: 0,
          isFavor: false
      );
      String? newId = await interactionRepo.addInteractionToFirestore(model);
      model.key = newId;
    }

    return model;
  }

  Future<void> updateInteraction(InteractionModel interactionModel) async {
    InteractionRepository interactionRepo = InteractionRepository();
    await interactionRepo.updateInteraction(interactionModel);
  }
}