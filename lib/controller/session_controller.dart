
// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:pcplus/models/shops/shop_repo.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/pages/widgets/util_widgets.dart';
import 'package:pcplus/services/authentication_service.dart';
import 'package:pcplus/services/nav_service.dart';
import 'package:pcplus/services/pref_service.dart';

import '../models/interactions/interaction_model.dart';
import '../models/interactions/interaction_repo.dart';
import '../models/shops/shop_model.dart';
import '../models/users/user_model.dart';
import '../pages/authentication/login/login.dart';
import '../services/delegate.dart';

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

  final Delegate<UserModel?> changeUserCallback = Delegate<UserModel?>();

  Future<void> loadUser(UserModel user) async {
    userID = user.userID;
    firstEnter = true;
    isSeller = user.userType == UserType.SHOP;

    if (isSeller) {
      ShopModel? shop = await _shopRepository.getShopById(userID!);
      await PrefService.saveShopData(shopData: shop!);
    }

    // Update FCM
    currentFcm = await getToken();
    user.activeFcm = currentFcm;
    await _userRepository.updateUser(user);
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

  Future<void> onUserModelChange() async {
    if (currentFcm != currentUser!.activeFcm) {
      AuthenticationService _auth = AuthenticationService();
      await _auth.signOut();
      await signOut();
      NavService.nav!.pushNamedAndRemoveUntil(
        LoginScreen.routeName,
            (Route<dynamic> route) => false,
      );
      UtilWidgets.createDialog(
          NavService.context!,
          "Thông báo",
          "Tài khoản của bạn đã được đăng nhập trên thiết bị khác.",
          () {
            NavService.nav!.pop();
          }
      );
    }
    changeUserCallback.invoke(currentUser);
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

  Future<void> onViewProduct(String itemID) async {
    if (isShop()) {
      return;
    }
    InteractionModel interactionModel = await getInteractionModel(itemID);
    interactionModel.clickTimes = interactionModel.clickTimes! + 1;
    await updateInteraction(interactionModel);
  }

  Future<void> onBuyProduct(String itemID, int amount) async {
    if (isShop()) {
      return;
    }
    InteractionModel interactionModel = await getInteractionModel(itemID);
    interactionModel.buyTimes = (interactionModel.buyTimes ?? 0) + amount;
    await updateInteraction(interactionModel);
  }

  Future<void> onRating(String itemID, double rating) async {
    if (isShop()) {
      return;
    }
    InteractionModel interactionModel = await getInteractionModel(itemID);
    interactionModel.rating = rating;
    await updateInteraction(interactionModel);
  }

  Future<String?> getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    return token;
  }
}