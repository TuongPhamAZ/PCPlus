import 'compress_service.dart';

class ExtractService {
  /// Phân giải dữ liệu thông số kỹ thuật
  /// Trường hợp đặc biệt: nếu không có dấu "|" thì tất cả thuộc "thông tin khác"
  static Map<String, dynamic> extractProperties(String detail) {
    // Kiểm tra xem có format mới (có dấu "|") hay không
    if (!detail.contains(CompressService.delimiter)) {
      // Trường hợp cũ - tất cả thuộc thông tin khác
      return {
        'tinhTrang': '',
        'nhaSanXuat': '',
        'ketNoi': <String>[],
        'hdh': <String>[],
        'baoHanh': '',
        'chungChi': <String>[],
        'vatLieu': '',
        'kichThuoc': '',
        'khoiLuong': '',
        'thongTinKhac': detail,
        'isOldFormat': true,
      };
    }

    try {
      // Sử dụng CompressService để giải nén
      final decompressed = CompressService.decompressProperties(detail);
      decompressed['isOldFormat'] = false;
      return decompressed;
    } catch (e) {
      // Nếu có lỗi trong quá trình giải nén, fallback về format cũ
      return {
        'tinhTrang': '',
        'nhaSanXuat': '',
        'ketNoi': <String>[],
        'hdh': <String>[],
        'baoHanh': '',
        'chungChi': <String>[],
        'vatLieu': '',
        'kichThuoc': '',
        'khoiLuong': '',
        'thongTinKhac': detail,
        'isOldFormat': true,
      };
    }
  }

  /// Phân tích thông tin bảo hành thành thời gian và loại
  static Map<String, String> parseBaoHanh(String baoHanh) {
    if (baoHanh.isEmpty) {
      return {'thoiGian': '', 'loai': ''};
    }

    // Format: "1 năm - Chính hãng"
    final parts = baoHanh.split(' - ');
    if (parts.length == 2) {
      return {
        'thoiGian': parts[0].trim(),
        'loai': parts[1].trim(),
      };
    }

    // Fallback nếu không đúng format
    return {'thoiGian': baoHanh, 'loai': ''};
  }

  /// Phân tích thông tin kích thước thành giá trị và đơn vị
  static Map<String, String> parseKichThuoc(String kichThuoc) {
    if (kichThuoc.isEmpty) {
      return {'giaTri': '', 'donVi': ''};
    }

    // Tìm đơn vị ở cuối chuỗi
    final units = ['mm', 'cm', 'inch'];
    for (String unit in units) {
      if (kichThuoc.endsWith(' $unit')) {
        return {
          'giaTri':
              kichThuoc.substring(0, kichThuoc.length - unit.length - 1).trim(),
          'donVi': unit,
        };
      }
    }

    // Fallback nếu không tìm thấy đơn vị
    return {'giaTri': kichThuoc, 'donVi': ''};
  }

  /// Phân tích thông tin khối lượng thành giá trị và đơn vị
  static Map<String, String> parseKhoiLuong(String khoiLuong) {
    if (khoiLuong.isEmpty) {
      return {'giaTri': '', 'donVi': ''};
    }

    // Tìm đơn vị ở cuối chuỗi
    final units = ['g', 'kg', 'lbs'];
    for (String unit in units) {
      if (khoiLuong.endsWith(' $unit')) {
        return {
          'giaTri':
              khoiLuong.substring(0, khoiLuong.length - unit.length - 1).trim(),
          'donVi': unit,
        };
      }
    }

    // Fallback nếu không tìm thấy đơn vị
    return {'giaTri': khoiLuong, 'donVi': ''};
  }
}
