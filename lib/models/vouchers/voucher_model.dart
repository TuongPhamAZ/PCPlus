import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {
  String? voucherID;
  String? name;
  String? description;
  int? condition;
  DateTime? startDate;
  DateTime? endDate;
  int? discount;
  int? quantity;

  static String collectionName = 'Vouchers';

  VoucherModel({
    this.voucherID,
    required this.name,
    required this.description,
    required this.condition,
    required this.startDate,
    required this.endDate,
    required this.discount,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'condition': condition,
        'startDate': startDate,
        'endDate': endDate,
        'discount': discount,
        'quantity': quantity,
      };

  static VoucherModel? fromJson(String id, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return VoucherModel(
      voucherID: id,
      name: json['name'] as String,
      description: json['description'] as String,
      condition: json['condition'] as int,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      discount: json['discount'] as int,
      quantity: json['quantity'] as int,
    );
  }

  /// Kiểm tra xem voucher có hiệu lực tại thời điểm hiện tại hay không
  bool isValid() {
    final now = DateTime.now();
    return startDate != null &&
        endDate != null &&
        now.isAfter(startDate!) &&
        now.isBefore(endDate!) &&
        (quantity ?? 0) > 0;
  }

  /// Kiểm tra xem voucher có đang trong thời gian hiệu lực hay không (bỏ qua quantity)
  bool isInValidTimeRange() {
    final now = DateTime.now();
    return startDate != null &&
        endDate != null &&
        now.isAfter(startDate!) &&
        now.isBefore(endDate!);
  }
}
