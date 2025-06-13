import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pcplus/config/api_config.dart';

class VectorApiService {
  // Singleton pattern
  static final VectorApiService _instance = VectorApiService._internal();
  factory VectorApiService() => _instance;
  VectorApiService._internal();

  /// Thêm sản phẩm mới và tạo vector đặc trưng
  ///
  /// [productId] - ID của sản phẩm
  /// [imageUrls] - Danh sách URL ảnh của sản phẩm
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> addProduct({
    required String productId,
    required List<String> imageUrls,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.addProductUrl);

      final requestBody = {
        'product_id': productId,
        'image_urls': imageUrls,
      };

      print('VectorApiService: Adding product: $productId');
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
        print('VectorApiService: Add product success: $success');
        return success;
      } else {
        print(
            'Error adding product: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in addProduct: $e');
      return false;
    }
  }

  /// Cập nhật vector đặc trưng cho sản phẩm
  ///
  /// [productId] - ID của sản phẩm cần cập nhật
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> updateProduct({
    required String productId,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.updateProductUrl);

      final requestBody = {
        'product_id': productId,
      };

      print('VectorApiService: Updating product: $productId');
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
        print('VectorApiService: Update product success: $success');
        return success;
      } else {
        print(
            'Error updating product: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in updateProduct: $e');
      return false;
    }
  }

  /// Xóa vector đặc trưng của sản phẩm
  ///
  /// [productId] - ID của sản phẩm cần xóa
  ///
  /// Returns true nếu thành công, false nếu thất bại
  Future<bool> deleteProduct({
    required String productId,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.deleteProductUrl);

      final requestBody = {
        'product_id': productId,
      };

      print('VectorApiService: Deleting product: $productId');
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
        print('VectorApiService: Delete product success: $success');
        return success;
      } else {
        print(
            'Error deleting product: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in deleteProduct: $e');
      return false;
    }
  }

  /// Tìm kiếm sản phẩm bằng hình ảnh
  ///
  /// [imageUrl] - URL của ảnh cần tìm kiếm
  /// [topK] - Số lượng kết quả tối đa
  /// [similarityThreshold] - Ngưỡng độ tương đồng tối thiểu (0.0 - 1.0)
  ///
  /// Returns danh sách ID sản phẩm tìm được hoặc null nếu thất bại
  Future<List<String>?> searchProducts({
    required String imageUrl,
    int topK = 10,
    double similarityThreshold = 0.7,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.searchProductUrl);

      final requestBody = {
        'image_url': imageUrl,
        'top_k': topK,
        'similarity_threshold': similarityThreshold,
      };

      print('VectorApiService: Searching products');
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
        if (responseData['status'] == 'success') {
          final results = List<String>.from(responseData['results']);
          print('VectorApiService: Found ${results.length} products: $results');
          return results;
        }
      }
      print(
          'Error searching products: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Exception in searchProducts: $e');
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

      print('VectorApiService: Health check status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        bool healthy = responseData['status'] == 'healthy';
        print('VectorApiService: Backend health: $healthy');
        return healthy;
      }
      return false;
    } catch (e) {
      print('Exception in checkBackendHealth: $e');
      return false;
    }
  }

  // ===== LEGACY METHODS (để tương thích với code cũ) =====

  /// [DEPRECATED] Sử dụng addProduct thay thế
  Future<bool> addNewProduct({
    required String productId,
    required String shopId,
    required List<String> reviewImages,
    required List<Map<String, String>> colors,
  }) async {
    // Tạo danh sách tất cả ảnh
    List<String> allImages = [...reviewImages];
    for (var color in colors) {
      if (color['image'] != null && color['image']!.isNotEmpty) {
        allImages.add(color['image']!);
      }
    }

    return await addProduct(
      productId: productId,
      imageUrls: allImages,
    );
  }

  /// [DEPRECATED] Sử dụng addProduct thay thế
  Future<bool> addProductImages({
    required String shopId,
    required List<Map<String, dynamic>> productImages,
  }) async {
    print('Warning: addProductImages is deprecated. Use addProduct instead.');
    return false;
  }

  /// [DEPRECATED] Sử dụng deleteProduct thay thế
  Future<bool> removeProductImages({
    required String shopId,
    required List<String> productIds,
  }) async {
    print(
        'Warning: removeProductImages is deprecated. Use deleteProduct instead.');
    return false;
  }

  /// [DEPRECATED] Sử dụng updateProduct thay thế
  Future<bool> updateProductImages({
    required String shopId,
    required String productId,
    List<String>? imagesToRemove,
    List<Map<String, dynamic>>? imagesToAdd,
  }) async {
    print(
        'Warning: updateProductImages is deprecated. Use updateProduct instead.');
    return false;
  }

  /// [DEPRECATED] Không còn sử dụng
  Future<Map<String, dynamic>?> getDatabaseStats() async {
    print('Warning: getDatabaseStats is deprecated.');
    return null;
  }
}
