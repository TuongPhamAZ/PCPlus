// import 'package:pcplus/builders/object_builders/list_item_data_builder.dart';
// import 'package:pcplus/builders/object_builders/list_object_builder_director.dart';
// import 'package:pcplus/const/order_status.dart';
// import 'package:pcplus/models/in_cart_items/in_cart_item_repo.dart';
// import 'package:pcplus/models/items/item_model.dart';
// import 'package:pcplus/models/items/item_repo.dart';
// import 'package:pcplus/models/notification/notification_repo.dart';
// import 'package:pcplus/models/orders/order_repo.dart';
// import 'package:pcplus/models/system/param_store_repo.dart';
// import 'package:pcplus/models/users/user_repo.dart';
// import 'package:pcplus/objects/in_cart_item_data.dart';
// import 'package:pcplus/services/notification_service.dart';
// import 'package:pcplus/services/pref_service.dart';
// import 'package:pcplus/singleton/user_singleton.dart';
// import 'package:pcplus/models/orders/order_address_model.dart';
//
// import '../models/orders/order_model.dart';
// import '../models/users/user_model.dart';
// import '../objects/suggest_item_data.dart';
//
// class CartSingleton {
//   static CartSingleton? _instance;
//   static CartSingleton getInstance() {
//     _instance ??= CartSingleton();
//     return _instance!;
//   }
//
//   final PrefService _pref = PrefService();
//   final UserSingleton _userSingleton = UserSingleton.getInstance();
//   final ItemRepository _itemRepo = ItemRepository();
//   final UserRepository _userRepo = UserRepository();
//   final InCartItemRepo _cartRepo = InCartItemRepo();
//
//   OrderAddressModel? address;
//
//   InCartItemData? buyNowItem;
//
//   List<ItemModel> items = [];
//   Map<String, UserModel> shops = {};
//   List<InCartItemData> inCartItems = [];
//   List<InCartItemData> onPaymentItems = [];
//   bool needUpdateCartUI = false;
//
//   Future<void> initCart() async {
//     address = await _pref.loadLocationData();
//     UserModel user = _userSingleton.currentUser!;
//     List<ItemModel> inCartProducts = await _cartRepo.getAllItemsInCart(user.userID!);
//
//     // validate data
//     for (ItemModel product in inCartProducts) {
//       ItemModel? item = await _itemRepo.getItemById(product.itemID!);
//       if (item == null) {
//         _cartRepo.deleteItemInCart(user.userID!, product.itemID!);
//       } else if (item.isEqual(product) == false) {
//         product = item;
//         _cartRepo.updateItemInCart(user.userID!, item);
//       }
//     }
//
//     // Build List ItemData
//     ListObjectBuilderDirector director = ListObjectBuilderDirector();
//     ListItemDataBuilder builder = ListItemDataBuilder();
//     await director.makeListItemData(
//         builder: builder,
//         items: inCartProducts,
//         shops: shops
//     );
//     List<ItemData> itemsData = builder.createList() as List<ItemData>;
//
//     // add item to cart
//     for (ItemData data in itemsData) {
//       addItemToCart(
//           itemData: data,
//           colorIndex: 0,
//           amount: 1
//       );
//     }
//   }
//
//   void clearData() {
//     items.clear();
//     shops.clear();
//     inCartItems.clear();
//     onPaymentItems.clear();
//   }
//
//   Future<void> fetchData() async {
//     UserModel user = _userSingleton.currentUser!;
//     List<String> deleteIds = [];
//
//     for (ItemModel item in items) {
//       ItemModel? previewItem = await _itemRepo.getItemById(item.itemID!);
//       if (previewItem == null) {
//         _cartRepo.deleteItemInCart(user.userID!, item.itemID!);
//         deleteIds.add(item.itemID!);
//       } else if (previewItem.isEqual(item) == false){
//         item = previewItem;
//         _cartRepo.updateItemInCart(user.userID!, previewItem);
//       }
//     }
//
//     // Remove item in cart
//     for (InCartItemData inCartItem in List.from(inCartItems)) {
//       if (deleteIds.contains(inCartItem.item!.itemID!)) {
//         inCartItems.remove(inCartItem);
//       }
//     }
//
//     for (UserModel shop in shops.values) {
//       shop = await _userRepo.getUserById(shop.userID!);
//     }
//   }
//
//   void addItemToCart({
//     required ItemData itemData,
//     required int colorIndex,
//     required int amount
//   }) {
//     needUpdateCartUI = true;
//     // Cache ItemModel
//     ItemModel? existItem = items.where((element) => element.itemID == itemData.product!.itemID).firstOrNull;
//     if (existItem == null) {
//       items.add(itemData.product!);
//     } else {
//       itemData.product = existItem;
//     }
//
//     // Cache ShopModel
//     if (shops.containsKey(itemData.shop!.userID!)) {
//       itemData.shop = shops[itemData.shop!.userID!];
//     } else {
//       shops[itemData.shop!.userID!] = itemData.shop!;
//     }
//     // Create Data
//     InCartItemData inCartItemData = InCartItemData(
//         item: itemData.product,
//         shop: itemData.shop,
//         rating: itemData.rating!,
//         colorIndex: colorIndex,
//         amount: amount,
//     );
//
//     // Check if item exist in cart
//     for (InCartItemData element in inCartItems) {
//       if (inCartItemData.item!.itemID! == element.item!.itemID!) {
//         if (inCartItemData.colorIndex != element.colorIndex) {
//           inCartItems.add(inCartItemData);
//         }
//         return;
//       }
//     }
//     // Add new item to cash
//     inCartItems.add(inCartItemData);
//     _cartRepo.addItemToUserCart(_userSingleton.currentUser!.userID!, inCartItemData.item!);
//   }
//
//   void removeInCartItem(InCartItemData itemData) {
//     UserModel user = _userSingleton.currentUser!;
//
//     inCartItems.remove(itemData);
//     _cartRepo.deleteItemInCart(user.userID!, itemData.item!.itemID!);
//   }
//
//   void addItemToPayment(InCartItemData itemData) {
//     onPaymentItems.add(itemData);
//   }
//
//   void removeItemInPayment(InCartItemData itemData) {
//     onPaymentItems.remove(itemData);
//   }
//
//   void resetAmount() {
//     for (var element in inCartItems) {
//       element.amount = 1;
//     }
//   }
//
//   void selectAllItemsInCart() {
//     for (var element in inCartItems) {
//       if (element.isBuyable()) {
//         element.isCheck = true;
//       }
//     }
//   }
//
//   void deselectAllItemsInCart() {
//     for (var element in inCartItems) {
//       element.isCheck = false;
//     }
//   }
//
//   void moveSelectedItemsToPayment() {
//     for (var element in inCartItems) {
//       if (element.isCheck) {
//         addItemToPayment(element);
//       }
//     }
//   }
//
//   Future<bool> validateIfSelectedItemsBuyable() async {
//     await fetchData();
//     bool buyable = true;
//     bool hasCheck = false;
//     for (var element in inCartItems) {
//       if (element.isCheck) {
//         hasCheck = true;
//         if (element.amount > element.item!.stock!) {
//           element.isCheck = false;
//           buyable = false;
//         }
//       }
//     }
//     return hasCheck && buyable;
//   }
//
//   Future<bool> validateOnPaymentItemsBuyable() async {
//     await fetchData();
//     bool buyable = true;
//     for (var element in onPaymentItems) {
//       if (element.amount > element.item!.stock!) {
//         element.isCheck = false;
//         buyable = false;
//       }
//     }
//     return buyable;
//   }
//
//   Future<bool> handleBuyNow({
//     required ItemData data,
//     required int colorIndex,
//     required int amount
//   }) async {
//     ItemModel? previewItem = await _itemRepo.getItemById(data.product!.itemID!);
//     if (previewItem == null) {
//       return false;
//     } else if (data.product!.isEqual(previewItem) == false) {
//       data.product = previewItem;
//     }
//     InCartItemData paymentData = InCartItemData(
//         item: data.product,
//         shop: data.shop,
//         rating: data.rating!,
//         colorIndex: colorIndex,
//         amount: amount
//     );
//     buyNowItem = paymentData;
//     addItemToPayment(paymentData);
//     return true;
//   }
//
//   Future<void> prepareForPayment() async {
//     for (var element in inCartItems) {
//       if (element.isCheck) {
//         onPaymentItems.add(element);
//       }
//     }
//   }
//
//   Future<void> performPayment() async {
//     OrderRepository orderRepository = OrderRepository();
//     ParamStoreRepository paramRepository = ParamStoreRepository();
//     NotificationService notificationService = NotificationService();
//
//     for (InCartItemData data in onPaymentItems) {
//       String userId = _userSingleton.currentUser!.userID!;
//       String shopId = data.shop!.userID!;
//
//       OrderModel newOrder = OrderModel(
//           orderID: await orderRepository.generateID(),
//           shopName: data.shop!.name,
//           receiverID: userId,
//           orderDate: DateTime.now(),
//           receiverName: _userSingleton.currentUser!.name!,
//           status: OrderStatus.PENDING_CONFIRMATION,
//           address: address,
//           itemModel: data.item!.toOrderItemModel(colorIndex: data.colorIndex),
//           deliveryMethod: data.deliveryMethod,
//           deliveryCost: data.deliveryCost,
//           amount: data.amount
//       );
//
//       orderRepository.addOrderToFirestore(userId, newOrder);
//       orderRepository.addOrderToFirestore(shopId, newOrder);
//       await notificationService.createOrderingNotification(newOrder);
//
//       await paramRepository.increaseOrderIdIndex();
//       removeInCartItem(data);
//     }
//   }
//
//   void clearOnPaymentItems() {
//     if (buyNowItem != null) {
//       buyNowItem = null;
//     }
//     for (InCartItemData item in onPaymentItems) {
//       item.clearPaymentInfo();
//     }
//     onPaymentItems.clear();
//   }
// }