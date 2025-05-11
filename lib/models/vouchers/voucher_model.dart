import 'package:cloud_firestore/cloud_firestore.dart';

class VoucherModel {

  String? voucherID;
  String? name;
  String? description;
  int? condition;
  DateTime? endDate;
  int? discount;
  List<String>? userPicked;

  static String collectionName = 'Vouchers';

  VoucherModel({
    this.voucherID,
    required this.name,
    required this.description,
    required this.condition,
    required this.endDate,
    required this.discount,
    required this.userPicked,
  });

  Map<String, dynamic> toJson() => {
    'voucherID': voucherID,
    'name': name,
    'description': description,
    'condition': condition,
    'endDate': endDate,
    'discount': discount,
    'userPicked': (userPicked ?? []).toList(),
  };

  static VoucherModel? fromJson(String id, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    final dataUsers = json['userPicked'] as List?;
    final listUsers = List.castFrom<Object?, Map<String, Object?>>(dataUsers!);

    return VoucherModel(
        voucherID: id,
        name: json['name'] as String,
        description: json['description'] as String,
        condition: json['condition'] as int,
        endDate: (json['endDate'] as Timestamp).toDate(),
        discount: json['discount'] as int,
        userPicked: listUsers.map((raw) => raw as String).toList(),
    );
  }
}