import 'package:file_picker/file_picker.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/models/items/item_with_seller.dart';
import 'package:pcplus/pages/manage_product/edit_product/edit_product_contract.dart';
import 'package:pcplus/services/image_storage_service.dart';
import 'package:pcplus/services/vector_api_service.dart';
import 'package:pcplus/objects/image_data.dart';

import '../../../models/items/color_model.dart';
import '../../../models/items/item_model.dart';
import '../edit_product/edit_product.dart';

class EditProductPresenter {
  final EditProductContract _view;
  EditProductPresenter(this._view);

  final ImageStorageService _imageStorageService = ImageStorageService();
  final ItemRepository _itemRepo = ItemRepository();
  final VectorApiService _vectorApiService = VectorApiService();

  ItemWithSeller? itemWithSeller;

  Future<void> handleEditProduct({
    required String name,
    required String description,
    required String detail,
    required String itemType,
    required int price,
    required int salePrice,
    required int amount,
    required List<ImageData> images,
    required List<ColorInfo> colors,
  }) async {
    _view.onWaitingProgressBar();

    if (images.isEmpty) {
      _view.onPopContext();
      _view.onEditFailed("Hãy chọn ảnh cho sản phẩm");
      return;
    }

    // Check ảnh color
    for (ColorInfo color in colors) {
      if (color.isNew == false || color.imageFile != null) {
        continue;
      }
      if (color.name.isEmpty) {
        _view.onPopContext();
        _view.onEditFailed("Hãy điền tên màu cho sản phẩm");
        return;
      }
      _view.onPopContext();
      _view.onEditFailed("Hãy chọn ảnh cho sản phẩm");
      return;
    }

    ItemModel itemModel = itemWithSeller!.item;

    // Cập nhật các field
    itemModel.name = name;
    itemModel.description = description;
    itemModel.detail = detail;
    itemModel.price = price;
    itemModel.discountPrice = salePrice;
    itemModel.stock = amount;

    // CẬP NHẬT ẢNH
    Set<String> deleteUrls = Set.from(itemModel.reviewImages!);
    deleteUrls.addAll(itemModel.colors!.map((color) => color.image!).toSet());

    // Cập nhật review Images
    itemModel.reviewImages = [];

    int index = 0;
    for (ImageData imageData in images) {
      if (imageData.isNew) {
        String pathName = _imageStorageService.formatProductImagePath(
            itemModel.itemID!, index);

        String? imagePath = await _imageStorageService.uploadImage(
            _imageStorageService.formatShopFolderName(itemModel.sellerID!),
            await _imageStorageService
                .convertFileToPlatformFile(imageData.file!),
            pathName);

        if (imagePath == null) {
          _view.onPopContext();
          _view.onEditFailed("Đã có lỗi xảy ra. Hãy thử lại sau.");
          return;
        }

        itemModel.reviewImages!.add(imagePath);
        index++;
      } else {
        itemModel.reviewImages!.add(imageData.path);
        deleteUrls.remove(imageData.path);
      }
    }

    // Cập nhật color
    itemModel.colors = [];

    index = 0;
    for (ColorInfo colorInfo in colors) {
      if (colorInfo.isNew) {
        // Post new color
        String pathName = "${_imageStorageService.formatProductImageColorPath(
          itemModel.itemID!,
          colorInfo.name,
        )}_$index";

        PlatformFile platformFile = await _imageStorageService
            .convertFileToPlatformFile(colorInfo.imageFile!);

        String? imagePath = await _imageStorageService.uploadImage(
            _imageStorageService.formatShopFolderName(itemModel.sellerID!),
            platformFile,
            pathName);

        index++;

        ColorModel colorModel = ColorModel(
          name: colorInfo.name,
          image: imagePath,
        );

        itemModel.colors?.add(colorModel);
      } else {
        // Save old color
        ColorModel colorModel = ColorModel(
          name: colorInfo.name,
          image: colorInfo.imageUrl,
        );
        itemModel.colors?.add(colorModel);
        deleteUrls.remove(colorModel.image);
      }
    }

    // Xóa ảnh
    for (String deleteUrl in deleteUrls) {
      await _imageStorageService.deleteImage(deleteUrl);
    }

    // Cập nhật sản phẩm trong database
    await _itemRepo.updateItem(itemModel);

    // 🚀 CẬP NHẬT VECTOR DATABASE
    print(
        '🔄 EditProductPresenter: Updating vector database for product: ${itemModel.itemID}');
    try {
      final vectorUpdateSuccess = await _vectorApiService.updateProduct(
        productId: itemModel.itemID!,
      );

      if (vectorUpdateSuccess) {
        print('✅ EditProductPresenter: Vector database updated successfully');
      } else {
        print(
            '⚠️ EditProductPresenter: Vector database update failed, but product was saved');
        // Không fail toàn bộ process vì sản phẩm đã được lưu thành công
      }
    } catch (e) {
      print('❌ EditProductPresenter: Vector database update error: $e');
      // Không fail toàn bộ process vì sản phẩm đã được lưu thành công
    }

    _view.onPopContext();
    _view.onEditSucceeded();
  }
}
