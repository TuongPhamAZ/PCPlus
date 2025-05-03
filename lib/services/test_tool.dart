import 'dart:math';

import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/users/user_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/services/random_tool.dart';

import '../const/product_status.dart';
import '../const/test_image.dart';
import '../const/test_item_name.dart';
import '../const/test_shop.dart';
import '../models/ratings/rating_model.dart';
import '../models/ratings/rating_repo.dart';

class TestTool {
  final RandomTool randomTool = RandomTool();

  final startDate = DateTime(2020, 1, 1);
  final endDate = DateTime(2024, 12, 31);

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

  UserModel getUserModel() {
    return UserModel(
      userID: randomTool.generateRandomString(20),
      name: randomTool.generateRandomText(10, true),
      email: randomTool.generateRandomEmail(),
      phone: randomTool.generateRandomPhoneNumber(),
      dateOfBirth: randomTool.generateRandomDate(DateTime(1970, 1, 1),
          DateTime.now().subtract(Duration(days: 365 * 18))),
      gender: 'male',
      userType: UserType.SHOP,
      avatarUrl:
          "https://product.hstatic.net/200000722513/product/b3ver24z_39c09f4db42b4078ac82013a19385b21_grande.png",
      money: randomTool.generateRandomNumber(100, 1000),
    );
  }

  void createRandomUserToFirestore(int length) {
    final UserRepository userRepository = UserRepository();

    for (int i = 0; i < length; i++) {
      userRepository.addUserToFirestore(getUserModel());
    }
  }

  void createRandomRating() {
    final RatingRepository ratingRepo = RatingRepository();
    final UserRepository userRepo = UserRepository();
    final ItemRepository itemRepo = ItemRepository();
    itemRepo.getAllItems().then((items) {
      userRepo.getAllUsers().then((users) {
        for (ItemModel item in items) {
          for (UserModel user in users) {
            RatingModel rating = RatingModel(
              itemID: item.itemID,
              userID: user.userID,
              rating: randomTool.generateRandomNumber(1, 5).toDouble(),
              comment: randomTool.generateRandomText(18, true),
              date: randomTool.generateRandomDate(startDate, endDate),
              like: [],
              dislike: [],
            );
            ratingRepo.addRatingToFirestore(item.itemID!, rating);
          }
        }
      });
    });
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
}
