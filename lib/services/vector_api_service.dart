import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pcplus/config/api_config.dart';

class VectorApiService {
  // Singleton pattern
  static final VectorApiService _instance = VectorApiService._internal();
  factory VectorApiService() => _instance;
  VectorApiService._internal();

  /// Thêm ảnh sản phẩm vào vector database
  ///
  /// [shopId] - ID của shop
  /// [productImages] - Danh sách thông tin ảnh sản phẩm
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> addProductImages({
    required String shopId,
    required List<Map<String, dynamic>> productImages,
  }) async {
    try {
      print('VectorApiService: Adding product images for shop: $shopId');
      print('VectorApiService: Number of images: ${productImages.length}');

      final url = Uri.parse(ApiConfig.addProductImagesUrl);

      final requestBody = {
        'shop_id': shopId,
        'product_images': productImages
            .map((image) => {
                  'url': image['url'],
                  'filename': image['filename'],
                  'public_id': image['public_id'] ?? '',
                  'format': image['format'] ?? 'jpg',
                  'width': image['width'] ?? 0,
                  'height': image['height'] ?? 0,
                  'bytes': image['bytes'] ?? 0,
                })
            .toList(),
      };

      print('VectorApiService: Sending request to: $url');
      print('VectorApiService: Request body: ${json.encode(requestBody)}');

      final response = await http
          .post(
            url,
            headers: ApiConfig.defaultHeaders,
            body: json.encode(requestBody),
          )
          .timeout(ApiConfig.defaultTimeout);

      print('VectorApiService: Response status: ${response.statusCode}');
      print('VectorApiService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        bool success = responseData['status'] == 'success';
        print('VectorApiService: API call success: $success');
        return success;
      } else {
        print(
            'Error adding product images: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in addProductImages: $e');
      return false;
    }
  }

  /// Xóa ảnh sản phẩm khỏi vector database
  ///
  /// [shopId] - ID của shop
  /// [productIds] - Danh sách ID sản phẩm cần xóa
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> removeProductImages({
    required String shopId,
    required List<String> productIds,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.removeProductImagesUrl);

      final requestBody = {
        'shop_id': shopId,
        'product_ids': productIds,
      };

      final response = await http
          .post(
            url,
            headers: ApiConfig.defaultHeaders,
            body: json.encode(requestBody),
          )
          .timeout(ApiConfig.defaultTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        print(
            'Error removing product images: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in removeProductImages: $e');
      return false;
    }
  }

  /// Cập nhật ảnh sản phẩm trong vector database
  ///
  /// [shopId] - ID của shop
  /// [productId] - ID sản phẩm cần cập nhật
  /// [imagesToRemove] - Danh sách filename ảnh cần xóa (optional)
  /// [imagesToAdd] - Danh sách ảnh mới cần thêm (optional)
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> updateProductImages({
    required String shopId,
    required String productId,
    List<String>? imagesToRemove,
    List<Map<String, dynamic>>? imagesToAdd,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.updateProductImagesUrl);

      final requestBody = {
        'shop_id': shopId,
        'product_id': productId,
        if (imagesToRemove != null && imagesToRemove.isNotEmpty)
          'images_to_remove': imagesToRemove,
        if (imagesToAdd != null && imagesToAdd.isNotEmpty)
          'images_to_add': imagesToAdd
              .map((image) => {
                    'url': image['url'],
                    'filename': image['filename'],
                    'public_id': image['public_id'] ?? '',
                    'format': image['format'] ?? 'jpg',
                    'width': image['width'] ?? 0,
                    'height': image['height'] ?? 0,
                    'bytes': image['bytes'] ?? 0,
                  })
              .toList(),
      };

      final response = await http
          .post(
            url,
            headers: ApiConfig.defaultHeaders,
            body: json.encode(requestBody),
          )
          .timeout(ApiConfig.defaultTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        print(
            'Error updating product images: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in updateProductImages: $e');
      return false;
    }
  }

  /// Lấy thống kê database
  ///
  /// Returns Map chứa thông tin thống kê hoặc null nếu thất bại
  Future<Map<String, dynamic>?> getDatabaseStats() async {
    try {
      final url = Uri.parse(ApiConfig.getDatabaseStatsUrl);

      final response = await http.get(url).timeout(ApiConfig.shortTimeout);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return responseData['stats'];
        }
      }
      return null;
    } catch (e) {
      print('Exception in getDatabaseStats: $e');
      return null;
    }
  }

  /// Kiểm tra trạng thái backend
  ///
  /// Returns true nếu backend đang hoạt động, false nếu không
  Future<bool> checkBackendHealth() async {
    try {
      final url = Uri.parse(ApiConfig.healthCheckUrl);

      final response = await http.get(url).timeout(ApiConfig.shortTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Exception in checkBackendHealth: $e');
      return false;
    }
  }

  /// Tìm kiếm sản phẩm bằng ảnh (cho người mua)
  ///
  /// [imageUrl] - URL ảnh để tìm kiếm
  /// [topK] - Số lượng kết quả tối đa
  /// [similarityThreshold] - Ngưỡng độ tương tự
  ///
  /// Returns danh sách filename hoặc null nếu thất bại
  Future<List<String>?> searchProducts({
    required String imageUrl,
    int topK = 10,
    double similarityThreshold = 0.5,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.searchProductsUrl);

      final requestBody = {
        'image_url': imageUrl,
        'top_k': topK,
        'similarity_threshold': similarityThreshold,
      };

      print(
          'VectorApiService: Searching with request: ${json.encode(requestBody)}');

      final response = await http
          .post(
            url,
            headers: ApiConfig.defaultHeaders,
            body: json.encode(requestBody),
          )
          .timeout(ApiConfig.defaultTimeout);

      print('VectorApiService: Search response status: ${response.statusCode}');
      print('VectorApiService: Search response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('VectorApiService: Parsed response data: $responseData');

        if (responseData['status'] == 'success') {
          final filenames = List<String>.from(responseData['filenames'] ?? []);
          print('VectorApiService: Extracted filenames: $filenames');
          return filenames;
        } else {
          print(
              'VectorApiService: Search not successful. Status: ${responseData['status']}');
        }
      } else {
        print(
            'VectorApiService: HTTP error: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('Exception in searchProducts: $e');
      return null;
    }
  }
}
