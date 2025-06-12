class ApiConfig {
  // Backend URL - sử dụng IP thực của máy tính
  static const String _developmentUrl = 'http://192.168.1.4:8000';
  static const String _productionUrl = 'https://your-backend-domain.com';

  // Chọn môi trường hiện tại
  static const bool _isDevelopment = true;

  static String get baseUrl =>
      _isDevelopment ? _developmentUrl : _productionUrl;

  // Endpoint paths
  static const String addProductImages = '/shop/add-product-images';
  static const String removeProductImages = '/shop/remove-product-images';
  static const String updateProductImages = '/shop/update-product-images';
  static const String getDatabaseStats = '/shop/database-stats';
  static const String healthCheck = '/health';
  static const String searchProducts = '/buyer/search-products';
  static const String searchProductsByFilename =
      '/buyer/search-products-by-filename';
  static const String searchProductsDetailed =
      '/buyer/search-products-detailed';

  // Timeout settings
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);

  // HTTP headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Full URL helpers
  static String get addProductImagesUrl => '$baseUrl$addProductImages';
  static String get removeProductImagesUrl => '$baseUrl$removeProductImages';
  static String get updateProductImagesUrl => '$baseUrl$updateProductImages';
  static String get getDatabaseStatsUrl => '$baseUrl$getDatabaseStats';
  static String get healthCheckUrl => '$baseUrl$healthCheck';
  static String get searchProductsUrl => '$baseUrl$searchProducts';
  static String get searchProductsByFilenameUrl =>
      '$baseUrl$searchProductsByFilename';
  static String get searchProductsDetailedUrl =>
      '$baseUrl$searchProductsDetailed';
}
