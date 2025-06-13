import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/shops/shop_repo.dart';
import 'package:pcplus/models/vouchers/voucher_repo.dart';
import 'package:pcplus/pages/home/shop_home/shop_home_contract.dart';
import 'package:pcplus/services/image_storage_service.dart';
import 'package:pcplus/services/vector_api_service.dart';
import 'package:pcplus/services/pref_service.dart';
import '../../../models/items/color_model.dart';
import '../../../models/items/item_with_seller.dart';
import '../../../models/shops/shop_model.dart';
import '../../../models/vouchers/voucher_model.dart';

class ShopHomePresenter {
  final ShopHomeContract _view;
  ShopHomePresenter(this._view);

  final SessionController _sessionController = SessionController.getInstance();
  final ItemRepository _itemRepo = ItemRepository();
  final VoucherRepository _voucherRepo = VoucherRepository();
  // final UserRepository _userRepo = UserRepository();
  final ShopRepository _shopRepo = ShopRepository();
  final ImageStorageService _imageStorageService = ImageStorageService();
  final VectorApiService _vectorApiService = VectorApiService();

  String? userId;
  ShopModel? seller;

  // List<ItemModel> itemModels = [];
  // List<ItemData> itemsData = [];

  Stream<List<ItemWithSeller>>? userItemsStream;
  Stream<List<VoucherModel>>? voucherStream;

  Future<void> getData() async {
    // await _shopSingleton.initShopData();
    // await _shopSingleton.initShopData();
    // if (_userSingleton.firstEnter) {
    //
    //   _userSingleton.firstEnter = false;
    // } else {
    //
    // }

    if (_sessionController.isShop()) {
      userId = _sessionController.userID;
      seller = await PrefService.loadShopData();
    } else {
      seller = await _shopRepo.getShopById(userId!);
    }

    userItemsStream = _itemRepo.getItemsWithSellerStreamBySellerID(userId!);
    voucherStream = _voucherRepo.getShopVouchersStream(seller!.shopID!);

    _view.onLoadDataSucceeded();
  }

  Future<void> handleItemEdit(ItemWithSeller itemData) async {
    // _shopSingleton.editedItem = itemData;
    _view.onItemEdit(itemData);
  }

  Future<void> handleItemDelete(ItemWithSeller itemData) async {
    // await _shopSingleton.deleteData(itemData);
    _view.onWaitingProgressBar();

    // Xóa sản phẩm khỏi database
    await _itemRepo.deleteItemById(itemData.item.itemID!);

    // Xóa ảnh khỏi storage
    for (String imagePath in itemData.item.reviewImages!) {
      await _imageStorageService.deleteImage(imagePath);
    }
    for (ColorModel colorImg in itemData.item.colors!) {
      await _imageStorageService.deleteImage(colorImg.image!);
    }

    // 🗑️ XÓA VECTOR DATABASE
    print(
        '🗑️ ShopHomePresenter: Deleting vector database for product: ${itemData.item.itemID}');
    try {
      final vectorDeleteSuccess = await _vectorApiService.deleteProduct(
        productId: itemData.item.itemID!,
      );

      if (vectorDeleteSuccess) {
        print('✅ ShopHomePresenter: Vector database deleted successfully');
      } else {
        print(
            '⚠️ ShopHomePresenter: Vector database delete failed, but product was removed');
        // Không fail toàn bộ process vì sản phẩm đã được xóa thành công
      }
    } catch (e) {
      print('❌ ShopHomePresenter: Vector database delete error: $e');
      // Không fail toàn bộ process vì sản phẩm đã được xóa thành công
    }

    _view.onPopContext();
    _view.onItemDelete();
  }

  Future<void> handleItemPressed(ItemWithSeller item) async {
    _view.onItemPressed(item);
  }

  void handleBack() {
    _view.onBack();
  }

  // TODO: Voucher
  void handleEditVoucher(VoucherModel model) {
    _view.onVoucherEdit(model);
  }

  Future<void> handleDeleteVoucher(VoucherModel model) async {
    _view.onWaitingProgressBar();
    await _voucherRepo.deleteVoucherById(seller!.shopID!, model.voucherID!);
    _view.onVoucherDelete(model);
  }

  void handleViewVoucher(VoucherModel model) {
    _view.onVoucherPressed(model);
  }
}
