class CompressService {
  static const String delimiter = "|";
  static const String multiValueDelimiter = ";";

  /// Nén dữ liệu thuộc tính thành chuỗi
  /// Thứ tự: Tình trạng|Nhà Sản xuất|Loại kết nối|Hệ điều hành tương thích|Bảo hành|Chứng chỉ|Vật liệu|Kích thước|Khối lượng|Thông tin khác
  static String compressProperties({
    required String tinhTrang,
    required String nhaSanXuat,
    required List<String> ketNoi,
    required List<String> hdh,
    required String baoHanh,
    required List<String> chungChi,
    required String vatLieu,
    required String kichThuoc,
    required String khoiLuong,
    String? thongTinKhac,
  }) {
    return [
      tinhTrang,
      nhaSanXuat,
      ketNoi.join(multiValueDelimiter),
      hdh.join(multiValueDelimiter),
      baoHanh,
      chungChi.join(multiValueDelimiter),
      vatLieu,
      kichThuoc,
      khoiLuong,
      thongTinKhac ?? '',
    ].join(delimiter);
  }

  /// Giải nén chuỗi thành dữ liệu thuộc tính
  static Map<String, dynamic> decompressProperties(String compressed) {
    final parts = compressed.split(delimiter);
    if (parts.length != 10) {
      throw ArgumentError('Invalid compressed string format');
    }

    return {
      'tinhTrang': parts[0],
      'nhaSanXuat': parts[1],
      'ketNoi': parts[2]
          .split(multiValueDelimiter)
          .where((s) => s.isNotEmpty)
          .toList(),
      'hdh': parts[3]
          .split(multiValueDelimiter)
          .where((s) => s.isNotEmpty)
          .toList(),
      'baoHanh': parts[4],
      'chungChi': parts[5]
          .split(multiValueDelimiter)
          .where((s) => s.isNotEmpty)
          .toList(),
      'vatLieu': parts[6],
      'kichThuoc': parts[7],
      'khoiLuong': parts[8],
      'thongTinKhac': parts[9],
    };
  }
}
