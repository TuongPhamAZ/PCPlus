import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcplus/const/feedbacks.dart';
import 'package:pcplus/models/interactions/interaction_model.dart';
import 'package:pcplus/models/interactions/interaction_repo.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/shops/shop_repo.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/services/random_tool.dart';
import 'package:pcplus/services/vector_api_service.dart';

import '../const/product_status.dart';
import '../const/test_image.dart';
import '../const/test_item_name.dart';
import '../const/test_shop.dart';
import '../models/ratings/rating_model.dart';
import '../models/ratings/rating_repo.dart';
import '../models/shops/shop_model.dart';

class TestTool {
  final RandomTool randomTool = RandomTool();

  final startDate = DateTime(2020, 1, 1);
  final endDate = DateTime(2025, 7, 5);

  List<String> testColor = ["Black", "Grey", "White"];

  ItemModel getRandomItemModel() {
    return ItemModel(
        itemID: "PCP${randomTool.generateRandomNumberString(10)}",
        name: demoNameItem[
            randomTool.generateRandomNumber(0, demoNameItem.length - 1)],
        itemType: randomTool.generateRandomText(1, true),
        sellerID: demoSellerID[
            randomTool.generateRandomNumber(0, demoSellerID.length - 1)],
        addDate: randomTool.generateRandomDate(startDate, endDate),
        price: randomTool.generateRandomPrice(1, 100, 4),
        stock: randomTool.generateRandomNumber(100, 1000),
        status: ProductStatus.BUYABLE,
        detail: randomTool.generateRandomString(40),
        reviewImages: testImages,
        colors: [],
        description: randomTool.generateRandomString(20),
        sold: randomTool.generateRandomNumber(100, 1000),
        rating: randomTool.generateRandomNumber(1, 5).toDouble()
    );
  }

  List<ItemModel> getRandomItemModelList(int length) {
    List<ItemModel> result = [];
    for (int i = 0; i < length; i++) {
      result.add(getRandomItemModel());
    }
    return result;
  }

  void pushRandomItemToFirestore(int length) {
    final ItemRepository itemRepository = ItemRepository();

    List<ItemModel> items = getRandomItemModelList(length);
    for (ItemModel model in items) {
      itemRepository.addItemToFirestore(model);
    }
  }

  UserModel getUserModel(String userType) {
    return UserModel(
      userID: randomTool.generateRandomString(20),
      name: randomTool.generateRandomText(10, true),
      email: randomTool.generateRandomEmail(),
      phone: randomTool.generateRandomPhoneNumber(),
      dateOfBirth: randomTool.generateRandomDate(DateTime(1970, 1, 1),
          DateTime.now().subtract(const Duration(days: 365 * 18))),
      gender: randomTool.generateRandomNumber(0, 100) < 50 ? 'male' : 'female',
      userType: userType,
      avatarUrl:
          "https://product.hstatic.net/200000722513/product/b3ver24z_39c09f4db42b4078ac82013a19385b21_grande.png",
      money: randomTool.generateRandomNumber(100, 1000),
    );
  }

  Future<void> createRandomUserToFirestore(int length, String userType) async {
    final UserRepository userRepository = UserRepository();

    for (int i = 0; i < length; i++) {
      await userRepository.addUserToFirestore(getUserModel(userType));
    }
  }

  Future<void> createRandomRating() async {
    final RatingRepository ratingRepo = RatingRepository();
    final UserRepository userRepo = UserRepository();
    final InteractionRepository interactionRepo = InteractionRepository();
    final ItemRepository itemRepo = ItemRepository();

    List<ItemModel> items = await itemRepo.getAllItems();
    List<InteractionModel> interactions = await interactionRepo.getAllInteractions();

    await userRepo.getAllUsers().then((users) async {
      for (UserModel user in users) {

        for (InteractionModel interaction in interactions) {
          if (interaction.userID != user.userID) {
            continue;
          }

          double ratingNumber = interaction.rating!;
          // update item data
          for (ItemModel item in items) {
            if (item.itemID == interaction.itemID) {
              bool needUpdate = false;
              if (ratingNumber > 0) {
                // update rating
                double totalRating = item.rating! * item.ratingCount!;
                item.ratingCount = item.ratingCount! + 1;
                item.rating = (totalRating + ratingNumber) / item.ratingCount!;
                needUpdate = true;
              }
              // add new sell count
              if (interaction.buyTimes! > 0) {
                item.sold = item.sold! + interaction.buyTimes!;
                needUpdate = true;
              }

              if (needUpdate) await itemRepo.updateItem(item);
              break;
            }
          }

          String comment = "";
          if (ratingNumber <= 0){
            continue;
          } else if (ratingNumber <= 2) {
            comment = feedbackDislike[randomTool.generateRandomNumber(0, feedbackDislike.length - 1)];
          } else if (ratingNumber <= 4) {
            comment = feedbackNeutral[randomTool.generateRandomNumber(0, feedbackNeutral.length - 1)];
          } else {
            comment = feedbackLike[randomTool.generateRandomNumber(0, feedbackLike.length - 1)];
          }

          RatingModel rating = RatingModel(
            itemID: interaction.itemID,
            userID: user.userID,
            rating: ratingNumber,
            comment: comment,
            date: randomTool.generateRandomDate(startDate, endDate),
            like: [],
            dislike: [],
          );
          await ratingRepo.addRatingToFirestore(interaction.itemID!, rating);
        }
      }
    });
    debugPrint('Done!');
  }

  Future<void> createSampleItems() async {
    final String jsonString = await rootBundle.loadString('lib/sample/test_samples/items_v4.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    final List<ItemModel> items = jsonList.map((raw) => ItemModel.fromJson("", raw)).toList();

    final ItemRepository itemRepo = ItemRepository();
    final VectorApiService vectorApiService = VectorApiService();

    for (ItemModel item in items) {
      item.addDate = randomTool.generateRandomDate(startDate, endDate);
      item.discountTime = item.addDate;
      item.detail = item.description;
      await Future.delayed(const Duration(milliseconds: 50));
      String itemID = await itemRepo.addItemToFirestore(item);

      List<String> imageUrls = [];
      imageUrls.addAll(item.reviewImages!);
      imageUrls.addAll(item.colors!.map((v) => v.image!).toList());

      await vectorApiService.addProduct(
          productId: itemID,
           imageUrls: imageUrls,
      );
    }
    debugPrint('Done!');
  }

  Future<void> createSampleUsers() async {
    final String jsonStringUsers = await rootBundle.loadString('lib/sample/test_samples/user.json');
    final List<dynamic> jsonUsersList = jsonDecode(jsonStringUsers);
    final List<UserModel> users = jsonUsersList.map((raw) => UserModel.fromJson(raw)).toList();

    final UserRepository userRepository = UserRepository();

    for (UserModel user in users) {
      await userRepository.addUserToFirestore(user);
    }
  }

  Future<void> createSampleSellers() async {
    final String jsonStringSellers = await rootBundle.loadString('lib/sample/test_samples/user_seller_v2.json');
    final List<dynamic> jsonSellersList = jsonDecode(jsonStringSellers);
    final List<UserModel> sellers = jsonSellersList.map((raw) => UserModel.fromJson(raw)).toList();

    final String jsonStringShops = await rootBundle.loadString('lib/sample/test_samples/shop_v2.json');
    final List<dynamic> jsonShopsList = jsonDecode(jsonStringShops);
    final List<ShopModel> shops = jsonShopsList.map((raw) => ShopModel.fromJson(raw['shopID'], raw)).toList();

    final UserRepository userRepository = UserRepository();
    final ShopRepository shopRepository = ShopRepository();

    for (UserModel seller in sellers) {
      await userRepository.addUserToFirestore(seller);
    }

    for (ShopModel shop in shops) {
      await shopRepository.addShopToFirestore(shop);
    }
  }

  Future<void> reUpdateItems() async {
    final ItemRepository itemRepository = ItemRepository();
    List<ItemModel> items = await itemRepository.getAllItems();

    for (ItemModel item in items) {
      await itemRepository.updateItem(item);
    }
  }

  Future<void> waitRandomDuration(
      int minMilliseconds, int maxMilliseconds) async {
    final random = Random();

    // Tạo thời gian ngẫu nhiên từ minMilliseconds đến maxMilliseconds
    int randomMilliseconds =
        random.nextInt(maxMilliseconds - minMilliseconds + 1) + minMilliseconds;

    // Chờ trong khoảng thời gian ngẫu nhiên
    await Future.delayed(Duration(milliseconds: randomMilliseconds));
  }

  Future<void> createRandomInteractions() async {
    final ItemRepository itemRepository = ItemRepository();
    final UserRepository userRepository = UserRepository();
    final InteractionRepository interactionRepository = InteractionRepository();

    List<ItemModel> items = await itemRepository.getAllItems();
    List<UserModel> users = await userRepository.getAllUsers();

    for (UserModel user in users) {
      if (user.userType == UserType.USER && user.activeFcm!.isEmpty) {
        for (ItemModel item in items) {
          int chance = randomTool.generateRandomNumber(0, 100);

          if (chance < 40) {
            int clickTimes = randomTool.generateRandomNumber(2, 10);
            int buyTimes = randomTool.generateRandomNumber(0, max((clickTimes / 2).toInt(), 1));
            double rating = 0;
            if (buyTimes == 1) {
              rating = randomTool.generateRandomNumber(2, 5).toDouble();
            } else if (buyTimes > 1) {
              rating = randomTool.generateRandomNumber(4, 5).toDouble();
            }

            InteractionModel newInteraction = InteractionModel(
                userID: user.userID,
                itemID: item.itemID,
                clickTimes: clickTimes,
                buyTimes: buyTimes,
                rating: rating,
                isFavor: buyTimes > 0,
            );

            await interactionRepository.addInteractionToFirestore(newInteraction);
            await Future.delayed(const Duration(milliseconds: 50));
          }
        }
      }
    }
    debugPrint('Done!');
  }
}
