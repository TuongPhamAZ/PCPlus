import 'package:pcplus/builders/object_builders/object_builder_interface.dart';
import 'package:pcplus/models/interactions/interaction_repo.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/objects/data_object_interface.dart';

import '../../models/users/user_model.dart';
import '../../objects/suggest_item_data.dart';

class ListItemDataBuilder implements ListObjectBuilderInterface {
  List<ItemModel>? items = [];
  Map<String, UserModel>? shops = {};
  List<ItemData>? result = [];

  void setItemList(List<ItemModel> items) {
    this.items = items;
  }

  void setShopCache(Map<String, UserModel> shops) {
    this.shops = shops;
  }

  Future<void> build() async {
    final UserRepository userRepo = UserRepository();
    if (items == null || shops == null) {
      return;
    }

    result = [];
    for (ItemModel model in items!) {
      UserModel? shop;
      if (shops!.containsKey(model.sellerID!)) {
        shop = shops![model.sellerID!];
      } else {
        shop = await userRepo.getUserById(model.sellerID!);
        shops?[model.sellerID!] = shop;
      }

      ItemData data = ItemData(
          product: model,
          shop: shop
      );

      await data.loadRating();

      result!.add(data);
    }
  }

  @override
  List<DataObjectInterface> createList() {
    if (result == null) {
      return [];
    }
    return result as List<ItemData>;
  }

  @override
  void reset() {
    items = null;
    shops = null;
    result = null;
  }
}