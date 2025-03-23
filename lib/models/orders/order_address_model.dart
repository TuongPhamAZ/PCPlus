import 'package:mailer/mailer.dart';

class OrderAddressModel {

  String? receiverName;
  String? phone;
  String? address1;
  String? address2;

  OrderAddressModel({
    required this.receiverName,
    required this.phone,
    required this.address1,
    required this.address2,
  });

  Map<String, dynamic> toJson() => {
    'receiverName': receiverName,
    'phone': phone,
    'address1': address1,
    'address2': address2,
  };

  static OrderAddressModel fromJson(Map<String, dynamic> json) {
    return OrderAddressModel(
        receiverName: json['receiverName'] as String,
        phone: json['phone'] as String,
        address1: json['address1'] as String,
        address2: json['address2'] as String,
    );
  }

  static final emptyAddress = OrderAddressModel(
      receiverName: "",
      phone: "",
      address1: "",
      address2: ""
  );

  bool isValid() {
    return
        receiverName!.isNotEmpty
        && phone!.isNotEmpty
        && address1!.isNotEmpty
        && address2!.isNotEmpty;
  }

  String getFullAddress() {
    return "$address1, $address2";
  }
}