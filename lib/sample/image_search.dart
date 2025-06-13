import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcplus/services/vector_api_service.dart';
import 'package:pcplus/services/image_storage_service.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class ImageSearchTest extends StatefulWidget {
  const ImageSearchTest({super.key});
  static const String routeName = 'image_search_test';

  @override
  State<ImageSearchTest> createState() => _ImageSearchTestState();
}

class _ImageSearchTestState extends State<ImageSearchTest> {
  final ImagePicker _picker = ImagePicker();
  final VectorApiService _vectorApiService = VectorApiService();
  final ImageStorageService _imageStorageService = ImageStorageService();

  File? _selectedImage;
  List<String> _searchResults = [];
  bool _isSearching = false;
  bool _isCheckingHealth = false;
  String? _uploadedImageUrl;
  bool _backendHealthy = false;
  String _statusMessage = 'Chưa kiểm tra backend';

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  // Kiểm tra trạng thái backend
  Future<void> _checkBackendHealth() async {
    setState(() {
      _isCheckingHealth = true;
      _statusMessage = 'Đang kiểm tra backend...';
    });

    try {
      print('🔍 ImageSearchTest: Checking backend health...');
      final isHealthy = await _vectorApiService.checkBackendHealth();

      setState(() {
        _backendHealthy = isHealthy;
        _statusMessage = isHealthy
            ? '✅ Backend đang hoạt động bình thường'
            : '❌ Backend không phản hồi';
      });

      print('🔍 ImageSearchTest: Backend health check result: $isHealthy');
    } catch (e) {
      setState(() {
        _backendHealthy = false;
        _statusMessage = '❌ Lỗi kết nối backend: $e';
      });
      print('🔍 ImageSearchTest: Health check error: $e');
    } finally {
      setState(() {
        _isCheckingHealth = false;
      });
    }
  }

  // Chọn ảnh từ gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _searchResults.clear();
          _uploadedImageUrl = null;
        });
        print('📷 ImageSearchTest: Image selected: ${pickedFile.path}');
      }
    } catch (e) {
      print('📷 ImageSearchTest: Error picking image: $e');
      _showSnackBar('Lỗi khi chọn ảnh: $e');
    }
  }

  // Upload ảnh lên Cloudinary để có URL cho API search
  Future<String?> _uploadImageToCloudinary() async {
    if (_selectedImage == null) return null;

    try {
      print('☁️ ImageSearchTest: Starting image upload...');

      // Convert File to PlatformFile
      final platformFile =
          await _imageStorageService.convertFileToPlatformFile(_selectedImage!);

      // Upload to search folder
      final imageUrl = await _imageStorageService.uploadImage(
        'search', // Folder name for search images
        platformFile,
        'search_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('☁️ ImageSearchTest: Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('☁️ ImageSearchTest: Error uploading image: $e');
      return null;
    }
  }

  // Thực hiện tìm kiếm
  Future<void> _searchSimilarImages() async {
    if (_selectedImage == null) {
      _showSnackBar('Vui lòng chọn ảnh trước');
      return;
    }

    if (!_backendHealthy) {
      _showSnackBar('Backend không hoạt động. Vui lòng kiểm tra lại.');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });

    try {
      // Upload ảnh lên Cloudinary trước
      print('🔍 ImageSearchTest: Starting search process...');
      _showSnackBar('Đang upload ảnh...');

      final imageUrl = await _uploadImageToCloudinary();

      if (imageUrl == null) {
        _showSnackBar('❌ Lỗi khi upload ảnh');
        return;
      }

      setState(() {
        _uploadedImageUrl = imageUrl;
      });

      _showSnackBar('Đang tìm kiếm sản phẩm...');
      print('🔍 ImageSearchTest: Calling search API with URL: $imageUrl');

      // Gọi API search với thông số chi tiết
      final results = await _vectorApiService.searchProducts(
        imageUrl: imageUrl,
        topK: 10,
        similarityThreshold: 0.7,
      );

      print('🔍 ImageSearchTest: Search API response:');
      print('   - Results: $results');
      print('   - Type: ${results?.runtimeType}');
      print('   - Length: ${results?.length}');

      setState(() {
        if (results != null && results.isNotEmpty) {
          print('✅ ImageSearchTest: Found ${results.length} results: $results');
          _searchResults = results;
          _showSnackBar('✅ Tìm thấy ${results.length} sản phẩm tương tự');
        } else {
          print('❌ ImageSearchTest: No results found. Results = $results');
          _searchResults = [];
          _showSnackBar('❌ Không tìm thấy sản phẩm tương tự');
        }
      });
    } catch (e) {
      print('❌ ImageSearchTest: Search error: $e');
      _showSnackBar('Lỗi khi tìm kiếm: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tìm Kiếm Sản Phẩm Bằng Hình Ảnh',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkBackendHealth,
            tooltip: 'Kiểm tra lại backend',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trạng thái backend
            Card(
              color: _backendHealthy ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    if (_isCheckingHealth)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        _backendHealthy ? Icons.check_circle : Icons.error,
                        color: _backendHealthy ? Colors.green : Colors.red,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextDecor.robo14.copyWith(
                          color: _backendHealthy
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Phần chọn và hiển thị ảnh
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Chọn ảnh để tìm kiếm sản phẩm tương tự',
                      style: TextDecor.robo18Semi,
                    ),
                    const SizedBox(height: 16),

                    // Hiển thị ảnh đã chọn
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Chưa chọn ảnh',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Nút chọn ảnh
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: Text('Chọn ảnh', style: TextDecor.robo16Semi),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.main1,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nút tìm kiếm
            ElevatedButton.icon(
              onPressed: (_isSearching || !_backendHealthy)
                  ? null
                  : _searchSimilarImages,
              icon: _isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search),
              label: Text(
                _isSearching ? 'Đang tìm kiếm...' : 'Tìm kiếm sản phẩm',
                style: TextDecor.robo18Semi,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _backendHealthy ? Colors.blue : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Hiển thị URL ảnh đã upload (để debug)
            if (_uploadedImageUrl != null) ...[
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔗 URL ảnh đã upload:',
                        style: TextDecor.robo16Semi,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        _uploadedImageUrl!,
                        style:
                            TextDecor.robo12.copyWith(color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Kết quả tìm kiếm
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list_alt, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Kết quả tìm kiếm',
                          style: TextDecor.robo18Semi,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_searchResults.isEmpty && !_isSearching)
                      Center(
                        child: Text(
                          '🔍 Chưa có kết quả tìm kiếm\n\nHướng dẫn:\n1. Kiểm tra backend đang chạy\n2. Chọn ảnh sản phẩm\n3. Nhấn "Tìm kiếm sản phẩm"',
                          textAlign: TextAlign.center,
                          style: TextDecor.robo14
                              .copyWith(color: Colors.grey[600]),
                        ),
                      )
                    else if (_isSearching)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Đang xử lý ảnh và tìm kiếm...'),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ Tìm thấy ${_searchResults.length} sản phẩm tương tự:',
                            style: TextDecor.robo16Semi
                                .copyWith(color: Colors.green[700]),
                          ),
                          const SizedBox(height: 12),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _searchResults.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextDecor.robo16Semi.copyWith(
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Product ID: ${_searchResults[index]}',
                                            style: TextDecor.robo16Semi,
                                          ),
                                          Text(
                                            'Sản phẩm tương tự được tìm thấy',
                                            style: TextDecor.robo12.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
