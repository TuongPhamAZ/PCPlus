// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final String cloudName = 'dwvdph8s5';
  final String uploadPreset = 'pcplus_upload';

  List<PlatformFile>? _images;
  bool _isUploading = false;

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true, // cần thiết để lấy bytes
    );
    if (result != null) {
      setState(() {
        _images = result.files;
      });
    }
  }

  Future<void> _uploadAll() async {
    if (_images == null || _images!.isEmpty) return;
    setState(() {
      _isUploading = true;
    });

    for (var file in _images!) {
      await _uploadSingle(file, folderName: "thanhtuong");
    }

    setState(() {
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hoàn thành tải lên ${_images!.length} ảnh')),
    );
  }

  Future<void> _uploadSingle(PlatformFile file, {String folderName = "test_upload"}) async {
    try {
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      var request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folderName;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        var resStr = await response.stream.bytesToString();
        var jsonRes = json.decode(resStr);
        debugPrint('Uploaded: ${jsonRes['secure_url']}');
      } else {
        debugPrint('Upload lỗi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi upload ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Ảnh lên Cloudinary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn ảnh'),
            ),
            const SizedBox(height: 10),
            _images != null && _images!.isNotEmpty
                ? Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _images!.length,
                      itemBuilder: (context, index) {
                        return Image.memory(
                          _images![index].bytes!,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  )
                : const Expanded(
                    child: Center(
                      child: Text('Chưa có ảnh nào được chọn'),
                    ),
                  ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadAll,
              icon: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label:
                  Text(_isUploading ? 'Đang tải lên...' : 'Gửi lên Cloudinary'),
            ),
          ],
        ),
      ),
    );
  }
}
