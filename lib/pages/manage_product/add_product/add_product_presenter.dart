import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/pages/manage_product/add_product/add_product_contract.dart';
import 'package:pcplus/models/items/item_model.dart';
import 'package:pcplus/models/items/item_repo.dart';
import 'package:pcplus/services/image_storage_service.dart';
import 'package:pcplus/services/vector_api_service.dart';

import '../../../const/product_status.dart';
import '../../../models/items/color_model.dart';
import 'add_product.dart';

class AddProductPresenter {
  final AddProductContract _view;
  AddProductPresenter(this._view);

  final SessionController _sessionController = SessionController.getInstance();
  final ItemRepository _itemRepo = ItemRepository();

  final ImageStorageService _imageStorageService = ImageStorageService();
  final VectorApiService _vectorApiService = VectorApiService();

  Future<void> handleAddProduct({
    required String name,
    required String itemType,
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
      itemType: itemType,
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

    // Danh sách thông tin ảnh để gửi tới vector API
    List<Map<String, dynamic>> productImages = [];

    // Post Image
    int index = 0;
    for (PlatformFile image in images) {
      String pathName = _imageStorageService.formatProductImagePath(id, index);

      String? imagePath = await _imageStorageService.uploadImage(
          _imageStorageService.formatShopFolderName(model.sellerID!),
          image,
          pathName);
      if (imagePath == null) {
        _view.onPopContext();
        _view.onAddFailed("Đã có lỗi xảy ra. Hãy thử lại.");
        return;
      }
      index++;
      model.reviewImages?.add(imagePath);

      // Thêm thông tin ảnh để gửi tới vector API
      String basePathName = pathName.split('/').last;
      String filename = '${id}_$basePathName';

      // Debug logging
      debugPrint('Debug - Product ID: $id');
      debugPrint('Debug - PathName: $pathName');
      debugPrint('Debug - Base PathName: $basePathName');
      debugPrint('Debug - Final Filename: $filename');
      debugPrint('Debug - Image URL: $imagePath');

      productImages.add({
        'url': imagePath,
        'filename': filename,
        'public_id':
            '${_imageStorageService.formatShopFolderName(model.sellerID!)}/$pathName',
        'format': image.extension ?? 'jpg',
        'width': 0, // Cloudinary sẽ cung cấp thông tin này
        'height': 0,
        'bytes': image.size,
      });
    }

    // Post color image
    index = 0;
    for (ColorInfo colorInfo in colors) {
      String pathName = "${_imageStorageService.formatProductImageColorPath(
        id,
        colorInfo.name,
      )}_$index";

      PlatformFile platformFile = await _imageStorageService
          .convertFileToPlatformFile(colorInfo.image!);

      String? imagePath = await _imageStorageService.uploadImage(
          _imageStorageService.formatShopFolderName(model.sellerID!),
          platformFile,
          pathName);

      if (imagePath != null) {
        // Thêm ảnh màu vào danh sách vector API
        String colorBasePathName = pathName.split('/').last;
        String colorFilename = '${id}_$colorBasePathName';

        debugPrint('Debug Color - Product ID: $id');
        debugPrint('Debug Color - PathName: $pathName');
        debugPrint('Debug Color - Base PathName: $colorBasePathName');
        debugPrint('Debug Color - Final Filename: $colorFilename');
        debugPrint('Debug Color - Image URL: $imagePath');

        productImages.add({
          'url': imagePath,
          'filename': colorFilename,
          'public_id':
              '${_imageStorageService.formatShopFolderName(model.sellerID!)}/$pathName',
          'format': platformFile.extension ?? 'jpg',
          'width': 0,
          'height': 0,
          'bytes': platformFile.size ?? 0,
        });
      }

      index++;

      ColorModel colorModel = ColorModel(
        name: colorInfo.name,
        image: imagePath,
      );

      model.colors?.add(colorModel);
    }

    await _itemRepo.updateItem(model);

    // Gửi thông tin ảnh tới backend để tạo vector đặc trưng
    bool vectorSuccess = false;
    try {
      // Tạo danh sách tất cả URL ảnh
      List<String> allImageUrls = [];

      // Thêm ảnh review
      if (model.reviewImages != null) {
        allImageUrls.addAll(model.reviewImages!);
      }

      // Thêm ảnh màu
      if (model.colors != null) {
        for (var color in model.colors!) {
          if (color.image != null && color.image!.isNotEmpty) {
            allImageUrls.add(color.image!);
          }
        }
      }

      if (allImageUrls.isNotEmpty) {
        debugPrint(
            "Sending ${allImageUrls.length} images to vector API for product $id");

        vectorSuccess = await _vectorApiService.addProduct(
          productId: id,
          imageUrls: allImageUrls,
        );

        if (vectorSuccess) {
          debugPrint(
              "✅ Vector đặc trưng đã được tạo thành công cho sản phẩm $id");
        } else {
          debugPrint(
              "⚠️ Không thể tạo vector đặc trưng cho sản phẩm $id");
        }
      } else {
        debugPrint("⚠️ Không có ảnh nào để tạo vector đặc trưng");
      }
    } catch (e) {
      debugPrint("❌ Lỗi khi tạo vector đặc trưng: $e");
      vectorSuccess = false;
    }

    // Tắt loading sau khi TẤT CẢ quá trình hoàn tất
    _view.onPopContext();

    if (vectorSuccess) {
      _view.onAddSuccessWithVector();
    } else {
      _view.onAddSuccessWithoutVector();
    }
  }
}
