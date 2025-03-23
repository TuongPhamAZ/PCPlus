
import 'package:string_validator/string_validator.dart';

abstract class Utility {

  static String getAgeRange(int birthYear) {
    // Tìm khoảng 10 năm gần nhất với năm sinh
    int start = (birthYear ~/ 10) * 10; // Bắt đầu của khoảng
    return "$start";
  }

  static String getPriceRangeIndex(int price) {
    if (price <= 500000) {
      return "0";
    }
    if (price <= 1000000) {
      return "1";
    }
    if (price <= 5000000) {
      return "2";
    }
    if (price <= 10000000) {
      return "3";
    }
    return "4";
  }

  static String formatSoldCount(int sold) {
    String value = "";

    if (sold < 10000) {
      value = sold.toString();
    } else if (sold < 1000000) {
      double transform = sold / 1000;
      value = "${transform.toStringAsFixed(1)}k";
    } else if (sold < 1000000000) {
      double transform = sold / 1000000;
      value = "${transform.toStringAsFixed(1)}M";
    }

    return value;
  }

  static String formatCurrency(int? amount) {
    const String currency = "đ";

    if (amount == null){
      return "00,000 $currency";
    }

    String value = amount.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    return "$value $currency";
  }

  static String formatRatingValue(double? value) {
    return value?.toStringAsFixed(1) ?? "4.5";
  }

  static String extractDigits(String input) {
    // Sử dụng biểu thức chính quy để tìm tất cả các chữ số
    RegExp regExp = RegExp(r'\d+'); // \d là ký tự đại diện cho chữ số
    Iterable<Match> matches = regExp.allMatches(input);

    // Lấy tất cả các chữ số tìm được và nối chúng lại thành một chuỗi
    String result = matches.map((match) => match.group(0)).join();
    return result;
  }

  static String formatDetailDateFromDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return "hh:mm dd/MM/YYYY";
    }

    final String time = "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    final String date = "${dateTime.day.toString().padLeft(2,'0')}/${dateTime.month.toString().padLeft(2,'0')}/${dateTime.year}";
    return "$time $date";
  }

  static String formatDateFromDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return "dd/MM/YYYY";
    }
    return "${dateTime.day.toString().padLeft(2,'0')}/${dateTime.month.toString().padLeft(2,'0')}/${dateTime.year}";
  }

  static bool listStringIsEqual (List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) {
      return true;
    } else if (list1 == null || list2 == null) {
      return false;
    }

    if (list1.length != list2.length) {
      return false;
    }
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].equals(list2[i]) == false) {
        return false;
      }
    }
    return true;
  }
}

abstract class TestData {
  static const DEMO_IMAGE_PATH = "https://product.hstatic.net/1000153276/product/fdff6b5d7e82473a866035f7964c3ff6_0ee0b6782499424ebff09bf020125ddd_grande.png";
}