import 'dart:io';

import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product_contract.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/services/image_storage_service.dart';

import '../../../const/product_status.dart';

class AddProductPresenter {
  final AddProductContract _view;
  AddProductPresenter(this._view);

  final SessionController _sessionController = SessionController.getInstance();
  final ItemRepository _itemRepo = ItemRepository();

  final ImageStorageService _imageStorageService = ImageStorageService();

  Future<void> handleAddProduct({
    required String name,
    required String description,
    required String detail,
    required int price,
    required int amount,
    required List<File> images,
  }) async {
    _view.onWaitingProgressBar();

    if (images.isEmpty) {
      _view.onPopContext();
      _view.onAddFailed("Hãy chọn ảnh cho sản phẩm");
      return;
    }

    List<String> urls = [];

    for (File image in images) {
      String? imagePath = await _imageStorageService.uploadImage(
          StorageFolderNames.PRODUCTS, image);
      if (imagePath == null) {
        _view.onPopContext();
        _view.onAddFailed("Something was wrong. Please try again.");
        return;
      }
      urls.add(imagePath);
    }

    ItemModel model = ItemModel(
        name: name,
        itemType: "Product",
        sellerID: _sessionController.userID,
        addDate: DateTime.now(),
        price: price,
        status: ProductStatus.BUYABLE,
        stock: amount,
        reviewImages: urls,
        detail: detail,
        description: description,
        sold: 0,
        colors: [],
        rating: 0
    );

    await _itemRepo.addItemToFirestore(model);
    _view.onPopContext();
    _view.onAddSucceeded();
  }
}
