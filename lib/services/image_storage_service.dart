import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageStorageService {
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final String cloudName = 'dwvdph8s5';
  final String uploadPreset = 'pcplus_upload';

  // Chọn ảnh từ thư viện
  Future<File?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      return file;
    }
    print("No image selected.");
    return null;
  }

  // Upload ảnh lên Cloudinary và trả về URL
  Future<String?> uploadImage(String folderName, PlatformFile file, String fileName) async {
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
          filename: fileName,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 200) {
        var resStr = await response.stream.bytesToString();
        var jsonRes = json.decode(resStr);
        debugPrint('Uploaded: ${jsonRes['secure_url']}');
        return jsonRes['secure_url'];
      } else {
        debugPrint('Upload lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi upload ảnh: $e');
    }
    return null;
  }

  // Xóa ảnh khỏi Cloudinary
  Future<void> deleteImage(String imageUrl) async {
    final String jsonString = await rootBundle.loadString('lib/sample/test_samples/user_seller.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);

    final apiKey = data["apiKey"];
    final apiSecret = data["apiSecret"];

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final publicId = extractPublicId(imageUrl);

    // Tạo signature
    final signatureData = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
    final signature = sha1.convert(utf8.encode(signatureData)).toString();

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/destroy');

    final response = await http.post(uri, body: {
      'public_id': publicId,
      'api_key': apiKey,
      'timestamp': timestamp.toString(),
      'signature': signature,
    });

    if (response.statusCode == 200) {
      print('Xoá thành công: ${response.body}');
    } else {
      print('Lỗi xoá ảnh: ${response.body}');
    }
  }

  Future<String> renameCloudinaryImage({
    required String fromPublicPath,
    required String toPublicId,
  }) async {
    final String jsonString = await rootBundle.loadString('lib/sample/test_samples/user_seller.json');
    final Map<String, dynamic> data = jsonDecode(jsonString);

    final apiKey = data["apiKey"];
    final apiSecret = data["apiSecret"];

    final fromPublicId = extractPublicId(fromPublicPath);

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Tạo signature
    final dataToSign = 'from_public_id=$fromPublicId&timestamp=$timestamp&to_public_id=$toPublicId$apiSecret';
    final signature = sha1.convert(utf8.encode(dataToSign)).toString();

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/rename');

    final response = await http.post(uri, body: {
      'from_public_id': fromPublicId,
      'to_public_id': toPublicId,
      'timestamp': timestamp.toString(),
      'api_key': apiKey,
      'signature': signature,
    });

    if (response.statusCode == 200) {
      debugPrint('Đổi tên thành công: ${response.body}');
      var jsonRes = json.decode(response.body);
      debugPrint('Uploaded: ${jsonRes['secure_url']}');
      return jsonRes['secure_url'];
    } else {
      print('Lỗi khi đổi tên: ${response.body}');
      return "";
    }
  }

  String extractPublicId(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final uploadIndex = segments.indexOf('upload');
    final publicPath = segments.sublist(uploadIndex + 1).join('/');

    return publicPath.replaceAll(RegExp(r'\.\w+$'), ''); // bỏ đuôi .jpg, .png, v.v.
  }

  String formatProductImagePath(String productID, int index) {
    return "$productID+$index+${DateTime.now()}";
  }

  String formatProductImageColorPath(String productID, String color) {
    return "$productID+$color+${DateTime.now()}";
  }

  String formatShopFolderName(String shopID) {
    return "PCPLUS/Shops/$shopID";
  }

  String formatAvatarFolderName() {
    return "PCPLUS/Avatars";
  }

  Future<PlatformFile> convertFileToPlatformFile(File file) async {
    final bytes = await file.readAsBytes();
    final length = await file.length();
    final name = file.path.split('/').last;

    return PlatformFile(
      name: name,
      path: file.path,
      size: length,
      bytes: bytes,
    );
  }
}

abstract class StorageFolderNames {
  static const String AVATARS = "avatars";
  static const String SHOP_AVATARS = "ShopAvatars";
  static const String PRODUCTS = "products";
}