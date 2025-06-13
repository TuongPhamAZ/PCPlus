// ignore_for_file: provide_deprecation_message

class ApiConfig {
  // Backend URL - sử dụng IP thực của máy tính
  static const String _developmentUrl = 'http://192.168.1.4:8000';

  static String get baseUrl => _developmentUrl;

  // New API Endpoint paths
  static const String addProduct = '/product/add';
  static const String updateProduct = '/product/update';
  static const String deleteProduct = '/product/delete';
  static const String searchProduct = '/product/search';
  static const String healthCheck = '/health';

  // Timeout settings
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);

  // HTTP headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Full URL helpers for new API
  static String get addProductUrl => '$baseUrl$addProduct';
  static String get updateProductUrl => '$baseUrl$updateProduct';
  static String get deleteProductUrl => '$baseUrl$deleteProduct';
  static String get searchProductUrl => '$baseUrl$searchProduct';
  static String get healthCheckUrl => '$baseUrl$healthCheck';

  // ===== DEPRECATED ENDPOINTS (for backward compatibility) =====
  @deprecated
  static const String addProductImages = '/shop/add-product-images';
  @deprecated
  static const String removeProductImages = '/shop/remove-product-images';
  @deprecated
  static const String updateProductImages = '/shop/update-product-images';
  @deprecated
  static const String getDatabaseStats = '/shop/database-stats';
  @deprecated
  static const String searchProducts = '/buyer/search-products';
  @deprecated
  static const String searchProductsByFilename =
      '/buyer/search-products-by-filename';
  @deprecated
  static const String searchProductsDetailed =
      '/buyer/search-products-detailed';

  // Deprecated URL helpers
  @deprecated
  static String get addProductImagesUrl => '$baseUrl$addProductImages';
  @deprecated
  static String get removeProductImagesUrl => '$baseUrl$removeProductImages';
  @deprecated
  static String get updateProductImagesUrl => '$baseUrl$updateProductImages';
  @deprecated
  static String get getDatabaseStatsUrl => '$baseUrl$getDatabaseStats';
  @deprecated
  static String get searchProductsUrl => '$baseUrl$searchProducts';
  @deprecated
  static String get searchProductsByFilenameUrl =>
      '$baseUrl$searchProductsByFilename';
  @deprecated
  static String get searchProductsDetailedUrl =>
      '$baseUrl$searchProductsDetailed';
}
