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
  String? _uploadedImageUrl;

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
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chọn ảnh: $e');
    }
  }

  // Upload ảnh lên Cloudinary để có URL cho API search
  Future<String?> _uploadImageToCloudinary() async {
    if (_selectedImage == null) return null;

    try {
      // Convert File to PlatformFile
      final platformFile =
          await _imageStorageService.convertFileToPlatformFile(_selectedImage!);

      // Upload to search folder
      final imageUrl = await _imageStorageService.uploadImage(
        'search', // Folder name for search images
        platformFile,
        'search_${DateTime.now().millisecondsSinceEpoch}',
      );

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Thực hiện tìm kiếm
  Future<void> _searchSimilarImages() async {
    if (_selectedImage == null) {
      _showSnackBar('Vui lòng chọn ảnh trước');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults.clear();
    });

    try {
      // Upload ảnh lên Cloudinary trước
      _showSnackBar('Đang upload ảnh...');
      final imageUrl = await _uploadImageToCloudinary();

      if (imageUrl == null) {
        _showSnackBar('Lỗi khi upload ảnh');
        return;
      }

      setState(() {
        _uploadedImageUrl = imageUrl;
      });

      _showSnackBar('Đang tìm kiếm...');

      // Gọi API search
      print('ImageSearchTest: Calling search API with URL: $imageUrl');
      final results = await _vectorApiService.searchProducts(
        imageUrl: imageUrl,
        topK: 10,
        similarityThreshold: 0.6,
      );

      print('ImageSearchTest: Search API returned: $results');

      setState(() {
        if (results != null && results.isNotEmpty) {
          print('ImageSearchTest: Found ${results.length} results: $results');
          _searchResults = results;
        } else {
          print('ImageSearchTest: No results found. Results = $results');
          _searchResults = ['Không tìm thấy ảnh tương tự'];
        }
      });

      _showSnackBar('Tìm kiếm hoàn tất: ${_searchResults.length} kết quả');
    } catch (e) {
      _showSnackBar('Lỗi khi tìm kiếm: $e');
      setState(() {
        _searchResults = ['Lỗi: $e'];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Tìm Kiếm Ảnh',
          style: TextDecor.robo24Medi.copyWith(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      'Chọn ảnh để tìm kiếm',
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
              onPressed: _isSearching ? null : _searchSimilarImages,
              icon: _isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search),
              label: Text(
                _isSearching ? 'Đang tìm kiếm...' : 'Tìm kiếm',
                style: TextDecor.robo18Semi,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
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
                        'URL ảnh đã upload:',
                        style: TextDecor.robo16Semi,
                      ),
                      const SizedBox(height: 4),
                      Text(
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
                          'Chưa có kết quả tìm kiếm',
                          style: TextDecor.robo14
                              .copyWith(color: Colors.grey[600]),
                        ),
                      )
                    else if (_isSearching)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tìm thấy ${_searchResults.length} filename:',
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
                                      width: 24,
                                      height: 24,
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
                                      child: Text(
                                        _searchResults[index],
                                        style: TextDecor.robo14,
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
