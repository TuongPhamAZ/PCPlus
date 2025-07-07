import 'dart:convert';
import 'package:flutter/services.dart';

class PropertyService {
  static Map<String, dynamic>? _propertyData;

  // Map tiếng Việt cho TinhTrang
  static const Map<String, String> _tinhTrangVietnamese = {
    'brandNew': 'Mới nguyên hộp',
    'likeNew': 'Như mới',
    'excellent': 'Tuyệt vời',
    'good': 'Tốt',
    'fair': 'Khá',
    'poor': 'Kém',
    'refurbished': 'Tân trang lại',
  };

  static Future<void> loadPropertyData() async {
    if (_propertyData != null) return;

    final String jsonString = await rootBundle.loadString('property.json');
    _propertyData = json.decode(jsonString);
  }

  static List<Map<String, String>> getTinhTrangWithVietnamese() {
    final List<String> englishList =
        List<String>.from(_propertyData?['TinhTrang'] ?? []);
    return englishList.map((englishValue) {
      return {
        'value': englishValue,
        'label': _tinhTrangVietnamese[englishValue] ?? englishValue,
      };
    }).toList();
  }

  static List<String> getTinhTrang() {
    return List<String>.from(_propertyData?['TinhTrang'] ?? []);
  }

  static List<String> getNhaSanXuat() {
    return List<String>.from(_propertyData?['NhaSanXuat'] ?? []);
  }

  static List<String> getKetNoi() {
    return List<String>.from(_propertyData?['KetNoi'] ?? []);
  }

  static List<String> getHDH() {
    return List<String>.from(_propertyData?['HDH'] ?? []);
  }

  static List<String> getChungChi() {
    return List<String>.from(_propertyData?['ChungChi'] ?? []);
  }

  static List<String> getVatLieu() {
    return List<String>.from(_propertyData?['VatLieu'] ?? []);
  }

  static List<Map<String, dynamic>> getBaoHanhThoiGian() {
    return List<Map<String, dynamic>>.from(
        _propertyData?['BaoHanh']?['ThoiGian'] ?? []);
  }

  static List<String> getBaoHanhLoai() {
    return List<String>.from(_propertyData?['BaoHanh']?['LoaiBaoHanh'] ?? []);
  }

  static List<String> getKichThuocDonVi() {
    return List<String>.from(_propertyData?['KichThuoc']?['DonVi'] ?? []);
  }

  static List<String> getKhoiLuongDonVi() {
    return List<String>.from(_propertyData?['KhoiLuong']?['DonVi'] ?? []);
  }
}
