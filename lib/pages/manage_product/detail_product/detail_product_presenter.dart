import 'package:pcplus/component/conversation_argument.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/chat/conversation_repo.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_model.dart';
import 'package:pcplus/models/in_cart_items/in_cart_item_repo.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/models/ratings/rating_repo.dart';
import 'package:pcplus/models/users/user_repo.dart';
import 'package:pcplus/pages/manage_product/detail_product/detail_product_contract.dart';
import 'package:flutter/foundation.dart';
import '../../../models/items/item_model.dart';
import '../../../models/ratings/rating_model.dart';
import '../../../models/users/user_model.dart';
import '../../../objects/review_data.dart';
import 'package:pcplus/models/chat/message_model.dart';

class DetailProductPresenter {
  final DetailProductContract _view;
  DetailProductPresenter(this._view);

  final RatingRepository _ratingRepo = RatingRepository();
  final ItemRepository _itemRepo = ItemRepository();
  final UserRepository _userRepo = UserRepository();
  final InCartItemRepo _inCartItemRepo = InCartItemRepo();
  // final ShopRepository _shopRepo = ShopRepository();
  final ConversationRepository _conversationRepo = ConversationRepository();
  final SessionController _sessionController = SessionController.getInstance();

  ItemWithSeller? itemWithSeller;
  List<RatingModel> ratings = [];

  List<ReviewData> ratingsData = [];
  int shopProductsCount = 0;
  ConversationModel? currentConversation;

  Future<void> getData() async {
    // Kiểm tra nếu đang chạy trong debug mode và có mock data
    if (kDebugMode && itemWithSeller?.item.itemID == "mock_id_123") {
      await _loadMockData();
      return;
    }

    // Logic gốc để load data từ API
    ratings.clear();
    ratingsData.clear();

    await SessionController.getInstance()
        .onViewProduct(itemWithSeller!.item.itemID!);

    List<ItemModel> sellerProducts =
        await _itemRepo.getItemsBySeller(itemWithSeller!.seller.shopID!);
    shopProductsCount = sellerProducts.length;

    ratings =
        await _ratingRepo.getAllRatingsByItemID(itemWithSeller!.item.itemID!);

    Map<String, UserModel?> users = {};
    for (RatingModel rating in ratings) {
      users[rating.userID!] = null;
    }

    List<UserModel> userModels =
        await _userRepo.getAllUsersByIdList(users.keys.toList());

    for (UserModel model in userModels) {
      users[model.userID!] = model;
    }

    for (RatingModel rating in ratings) {
      ratingsData.add(ReviewData(rating: rating, user: users[rating.userID!]));
    }

    _view.onLoadDataSucceeded();
  }

  // Hàm load mock data
  Future<void> _loadMockData() async {
    // Tạo mock reviews
    final mockRating1 = RatingModel(
        key: "rating_1",
        userID: "user_1",
        itemID: "mock_id_123",
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 5)),
        comment:
            "Sản phẩm tuyệt vời, hiệu năng mạnh mẽ, đáp ứng tốt nhu cầu chơi game và làm việc. Màn hình 144Hz rất mượt.",
        like: ["user_2", "user_3"],
        dislike: [],
        response: "Cảm ơn bạn đã đánh giá tích cực về sản phẩm.");

    final mockRating2 = RatingModel(
        key: "rating_2",
        userID: "user_2",
        itemID: "mock_id_123",
        rating: 4.0,
        date: DateTime.now().subtract(const Duration(days: 10)),
        comment:
            "Laptop chạy khá mát, thiết kế đẹp. Chỉ tiếc là pin không được lâu lắm.",
        like: ["user_1"],
        dislike: [],
        response: null);

    final mockRating3 = RatingModel(
        key: "rating_3",
        userID: "user_3",
        itemID: "mock_id_123",
        rating: 4.5,
        date: DateTime.now().subtract(const Duration(days: 15)),
        comment:
            "Máy rất ổn với tầm giá, màn hình đẹp, hiệu năng tốt. Giao hàng nhanh và đóng gói cẩn thận.",
        like: ["user_2", "user_4"],
        dislike: [],
        response: "Cảm ơn bạn đã ủng hộ shop!");

    // Tạo mock users
    final mockUser1 = UserModel(
        userID: "user_1",
        name: "Nguyễn Văn A",
        email: "nguyenvana@gmail.com",
        phone: "0901234567",
        dateOfBirth: DateTime(1995, 5, 20),
        gender: "Nam",
        userType: "user",
        avatarUrl: "https://i.pravatar.cc/150?img=1");

    final mockUser2 = UserModel(
        userID: "user_2",
        name: "Trần Thị B",
        email: "tranthib@gmail.com",
        phone: "0909876543",
        dateOfBirth: DateTime(1998, 8, 15),
        gender: "Nữ",
        userType: "user",
        avatarUrl: "https://i.pravatar.cc/150?img=5");

    final mockUser3 = UserModel(
        userID: "user_3",
        name: "Lê Văn C",
        email: "levanc@gmail.com",
        phone: "0912345678",
        dateOfBirth: DateTime(1990, 3, 10),
        gender: "Nam",
        userType: "user",
        avatarUrl: "https://i.pravatar.cc/150?img=8");

    // Tạo ReviewData
    ratingsData = [
      ReviewData(rating: mockRating1, user: mockUser1),
      ReviewData(rating: mockRating2, user: mockUser2),
      ReviewData(rating: mockRating3, user: mockUser3),
    ];

    shopProductsCount = 50; // Mock số lượng sản phẩm của shop

    // Báo thành công
    _view.onLoadDataSucceeded();
  }

  void handleBack() {
    _view.onBack();
  }

  Future<void> handleViewShop() async {
    // _view.onWaitingProgressBar();
    // _shopSingleton.changeShop(_itemSingleton.itemData!.shop!);
    // await _shopSingleton.initShopData();
    // _view.onPopContext();
    _view.onViewShop(itemWithSeller!.seller);
  }

  Future<void> handleAddToCart(
      {required int colorIndex, required int amount}) async {
    // Nếu đang trong mock mode, chỉ cần hiển thị progress và callback
    if (kDebugMode && itemWithSeller?.item.itemID == "mock_id_123") {
      _view.onWaitingProgressBar();
      await Future.delayed(
          const Duration(milliseconds: 500)); // Giả lập thời gian xử lý
      _view.onPopContext();
      _view.onAddToCart();
      return;
    }

    // Logic gốc để thêm vào giỏ hàng
    _view.onWaitingProgressBar();

    String userId = SessionController.getInstance().userID!;
    String itemId = itemWithSeller!.item.itemID!;

    InCartItemModel? temp =
        await _inCartItemRepo.getItemInCartByItemID(userId, itemId);

    if (temp == null) {
      InCartItemModel model = InCartItemModel(
        itemID: itemWithSeller!.item.itemID!,
        color: itemWithSeller!.item.colors![colorIndex],
        amount: amount,
        isSelected: false,
      );

      await _inCartItemRepo.addItemToUserCart(userId, model);
    } else {
      temp.color = itemWithSeller!.item.colors![colorIndex];
      temp.amount = amount;

      await _inCartItemRepo.updateItemInCart(userId, temp);
    }

    _view.onPopContext();
    _view.onAddToCart();
  }

  Future<void> handleBuyNow(
      {required int colorIndex, required int amount}) async {
    // Nếu đang trong mock mode, chỉ cần hiển thị progress và callback
    if (kDebugMode && itemWithSeller?.item.itemID == "mock_id_123") {
      _view.onWaitingProgressBar();
      await Future.delayed(
          const Duration(milliseconds: 500)); // Giả lập thời gian xử lý
      _view.onPopContext();
      _view.onBuyNow();
      return;
    }

    // Logic gốc để mua ngay
    _view.onWaitingProgressBar();

    String userId = SessionController.getInstance().userID!;
    String itemId = itemWithSeller!.item.itemID!;
    ItemModel? itemTemp = await _itemRepo.getItemById(itemId);
    if (itemTemp == null) {
      _view.onPopContext();
      _view.onError("Có lỗi xảy ra. Hãy thử lại sau.");
      return;
    } else if (itemTemp.stock! < amount) {
      _view.onPopContext();
      _view.onError("Sản phẩm này hiện không mua được");
      return;
    }

    await _inCartItemRepo.selectAllItemInCart(userId, false);

    InCartItemModel? inCartItemTemp =
        await _inCartItemRepo.getItemInCartByItemID(userId, itemId);
    if (inCartItemTemp == null) {
      inCartItemTemp = InCartItemModel(
        itemID: itemWithSeller!.item.itemID!,
        color: itemWithSeller!.item.colors![colorIndex],
        amount: amount,
        isSelected: true,
      );

      await _inCartItemRepo.addItemToUserCart(userId, inCartItemTemp);
    } else {
      inCartItemTemp.color = itemWithSeller!.item.colors![colorIndex];
      inCartItemTemp.amount = amount;
      inCartItemTemp.isSelected = true;
      await _inCartItemRepo.updateItemInCart(userId, inCartItemTemp);
    }

    _view.onPopContext();
    _view.onBuyNow();
  }

  Future<void> onSendResponse(RatingModel rating, String message) async {
    _view.onWaitingProgressBar();
    rating.response = message;
    await _ratingRepo.updateRating(rating);
    _view.onPopContext();
    _view.onResponseRatingSuccess();
  }

  /// Xử lý logic nhắn tin với shop
  Future<void> handleChatWithShop() async {
    if (itemWithSeller == null) {
      _view.onError("Không thể nhắn tin với shop lúc này");
      return;
    }

    ConversationModel? conversationModel = await _conversationRepo.getConversation(_sessionController.userID!, itemWithSeller!.seller.shopID!);


    ConversationArgument argument;
    ConversationModel? otherConversation;

    // Chưa có conversation
    if (conversationModel == null) {
      conversationModel = ConversationModel(
        id: itemWithSeller!.seller.shopID!,
        participantId: itemWithSeller!.seller.shopID!,
        participantName: itemWithSeller!.seller.name!,
        lastActivity: DateTime.now(),
        unreadCount: 0,
        lastMessage: null,
        participantAvatar: itemWithSeller!.seller.image!,
      );
    } else {
      otherConversation = await _conversationRepo.getConversation(conversationModel.participantId, _sessionController.userID!);
    }

    argument = ConversationArgument(
      ownerConversation: conversationModel,
      partnerConversation: otherConversation,
    );

    // Thông báo cho view chuyển đến chat detail
    _view.onChatWithShop(argument);
  }
}
