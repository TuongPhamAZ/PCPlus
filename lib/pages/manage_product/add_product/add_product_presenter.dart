import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product_contract.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/services/image_storage_service.dart';

import '../../../const/product_status.dart';
import '../../../models/items/color_model.dart';
import 'add_product.dart';

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
    required int discountPrice,
    required List<PlatformFile> images,
    required List<ColorInfo> colors,
  }) async {
    _view.onWaitingProgressBar();

    if (images.isEmpty) {
      _view.onPopContext();
      _view.onAddFailed("Hãy chọn ảnh cho sản phẩm");
      return;
    }

    ItemModel model = ItemModel(
        name: name,
        itemType: "Product",
        sellerID: _sessionController.userID,
        addDate: DateTime.now(),
        price: price,
        status: ProductStatus.BUYABLE,
        stock: amount,
        reviewImages: [],
        detail: detail,
        description: description,
        sold: 0,
        colors: [],
        rating: 0,
        discountPrice: discountPrice,
        discountTime: DateTime.now(),
    );

    String id = await _itemRepo.addItemToFirestore(model);

    // Post Image
    int index = 0;
    for (PlatformFile image in images) {
      String pathName = _imageStorageService.formatProductImagePath(
          id,
          index
      );
      
      String? imagePath = await _imageStorageService.uploadImage(
          _imageStorageService.formatShopFolderName(model.sellerID!),
          image,
          pathName
      );
      if (imagePath == null) {
        _view.onPopContext();
        _view.onAddFailed("Something was wrong. Please try again.");
        return;
      }
      index++;
      model.reviewImages?.add(imagePath);
    }

    // Post color image
    index = 0;
    for (ColorInfo colorInfo in colors) {
      String pathName = "${_imageStorageService.formatProductImageColorPath(
          id,
          colorInfo.name,
      )}_$index";

     PlatformFile platformFile = await _imageStorageService.convertFileToPlatformFile(colorInfo.image!);

      String? imagePath = await _imageStorageService.uploadImage(
          _imageStorageService.formatShopFolderName(model.sellerID!),
          platformFile,
          pathName
      );

      index ++;

      ColorModel colorModel = ColorModel(
        name: colorInfo.name,
        image: imagePath,
      );

      model.colors?.add(colorModel);
    }

    await _itemRepo.updateItem(model);

    _view.onPopContext();
    _view.onAddSucceeded();
  }
}
