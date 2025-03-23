import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/observers/publisher_interface.dart';
import 'package:pcplus/services/image_storage_service.dart';
import 'package:pcplus/singleton/user_singleton.dart';

import '../builders/object_builders/list_item_data_builder.dart';
import '../builders/object_builders/list_object_builder_director.dart';
import '../models/items/item_model.dart';
import '../models/users/user_model.dart';
import '../objects/suggest_item_data.dart';

class ShopSingleton extends PublisherInterface {
  static ShopSingleton? _instance;
  static ShopSingleton getInstance() {
    _instance ??= ShopSingleton();
    return _instance!;
  }

  final ItemRepository _itemRepository = ItemRepository();
  final UserSingleton _userSingleton = UserSingleton.getInstance();
  final ImageStorageService _imageStorageService = ImageStorageService();

  bool init = true;

  List<ItemModel> itemModels = [];
  List<ItemData> itemsData = [];
  ItemData? editedItem;

  UserModel? shop;

  void changeShop(UserModel shop) {
    this.shop = shop;
    init = true;
  }

  Future<void> initShopData() async {
    // if (init == false) {
    //   return;
    // }

    itemModels.clear();
    itemsData.clear();

    itemModels = await _itemRepository.getItemsBySeller(shop!.userID!);

    final ListItemDataBuilder builder = ListItemDataBuilder();
    final Map<String, UserModel> cacheShops = {};
    final ListObjectBuilderDirector director = ListObjectBuilderDirector();

    await director.makeListItemData(
        builder: builder,
        items: itemModels,
        shops: cacheShops
    );
    itemsData = builder.createList().cast<ItemData>();
    for (ItemData itemData in itemsData) {
      itemData.shop = shop;
    }
    init = false;
    reorder();
  }

  Future<void> addData(ItemModel itemModel) async {
    await _itemRepository.addItemToFirestore(itemModel);
    itemModels.add(itemModel);
    ItemData newData = ItemData(
      shop: shop,
      product: itemModel,
      rating: 0,
    );
    itemsData.add(newData);
    reorder();
    notifySubscribers();
  }

  void updateData(ItemData data) {
    _itemRepository.updateItem(data.product!);
    notifySubscribers();
  }

  Future<void> deleteData(ItemData data) async {
    for (String url in data.product!.reviewImages!) {
      try {
        await _imageStorageService.deleteImage(url);
      } catch(e) {
        print(e);
      }
    }
    _itemRepository.deleteItemById(data.product!.itemID!);
    itemsData.remove(data);
    itemModels.remove(data.product!);
    notifySubscribers();
  }

  void reorder() {
    itemsData.sort((element1, element2)
      => element1.product!.addDate!.compareTo(element2.product!.addDate!) * -1
    );
  }
}