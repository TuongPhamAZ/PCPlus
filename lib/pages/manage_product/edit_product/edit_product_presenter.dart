import 'package:pcplus/pages/manage_product/edit_product/edit_product_contract.dart';
import 'package:pcplus/services/image_storage_service.dart';
import 'package:pcplus/objects/image_data.dart';

import '../../../models/items/item_model.dart';
import '../../../objects/suggest_item_data.dart';

class EditProductPresenter {
  final EditProductContract _view;
  EditProductPresenter(this._view);

  final ImageStorageService _imageStorageService = ImageStorageService();

  Future<void> handleEditProduct({
    required String name,
    required String description,
    required String detail,
    required int price,
    required int amount,
    required List<ImageData> images,
  }) async {
    _view.onWaitingProgressBar();

    if (images.isEmpty) {
      _view.onPopContext();
      _view.onEditFailed("Hãy chọn ảnh cho sản phẩm");
      return;
    }

    // ItemData editedItemData = _shopSingleton.editedItem!;
    // ItemModel editedItemModel = _shopSingleton.editedItem!.product!;

    // List<String> deleteUrls = List.from(editedItemModel.reviewImages!);
    // List<String> urls = [];
    //
    // for (ImageData image in images) {
    //   if (image.isNew) {
    //     String? imagePath = await _imageStorageService.uploadImage(
    //         StorageFolderNames.PRODUCTS, image.file!);
    //     if (imagePath == null) {
    //       _view.onPopContext();
    //       _view.onEditFailed("Something was wrong. Please try again.");
    //       return;
    //     }
    //     urls.add(imagePath);
    //   } else {
    //     urls.add(image.path);
    //     deleteUrls.remove(image.path);
    //   }
    // }
    //
    // editedItemModel.reviewImages = urls;
    // for (String url in deleteUrls) {
    //   await _imageStorageService.deleteImage(url);
    // }
    //
    // editedItemModel.name = name;
    // editedItemModel.description = description;
    // editedItemModel.detail = detail;
    // editedItemModel.price = price;
    // editedItemModel.stock = amount;
    //
    // _shopSingleton.updateData(editedItemData);
    _view.onPopContext();
    _view.onEditSucceeded();
  }
}
