import 'dart:async';
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

  // StreamController để quản lý stream lifecycle
  StreamController<List<ItemWithSeller>>? _userItemsController;
  StreamController<List<VoucherModel>>? _voucherController;

  // Stream subscriptions để dispose
  StreamSubscription<List<ItemWithSeller>>? _userItemsSubscription;
  StreamSubscription<List<VoucherModel>>? _voucherSubscription;

  Stream<List<ItemWithSeller>>? get userItemsStream =>
      _userItemsController?.stream;
  Stream<List<VoucherModel>>? get voucherStream => _voucherController?.stream;

  bool _isDisposed = false;

  Future<void> getData() async {
    if (_isDisposed) return;

    // Dispose existing streams if any
    await _disposeStreams();

    if (_sessionController.isShop()) {
      userId = _sessionController.userID;
      seller = await PrefService.loadShopData();
    } else {
      seller = await _shopRepo.getShopById(userId!);
    }

    // Create new controllers
    _userItemsController = StreamController<List<ItemWithSeller>>.broadcast();
    _voucherController = StreamController<List<VoucherModel>>.broadcast();

    // Subscribe to repository streams
    _userItemsSubscription =
        _itemRepo.getItemsWithSellerStreamBySellerID(userId!).listen((data) {
      if (!_isDisposed && !_userItemsController!.isClosed) {
        _userItemsController!.add(data);
      }
    }, onError: (error) {
      if (!_isDisposed && !_userItemsController!.isClosed) {
        _userItemsController!.addError(error);
      }
    });

    _voucherSubscription =
        _voucherRepo.getShopVouchersStream(seller!.shopID!).listen((data) {
      if (!_isDisposed && !_voucherController!.isClosed) {
        _voucherController!.add(data);
      }
    }, onError: (error) {
      if (!_isDisposed && !_voucherController!.isClosed) {
        _voucherController!.addError(error);
      }
    });

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

  // Dispose streams khi không sử dụng nữa
  Future<void> _disposeStreams() async {
    await _userItemsSubscription?.cancel();
    await _voucherSubscription?.cancel();

    await _userItemsController?.close();
    await _voucherController?.close();

    _userItemsSubscription = null;
    _voucherSubscription = null;
    _userItemsController = null;
    _voucherController = null;
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await _disposeStreams();
  }
}
