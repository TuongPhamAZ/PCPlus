class VoucherOfUserModel {

  String? voucherID;
  String? shopID;

  static String collectionName = "Vouchers";

  VoucherOfUserModel(
      {
        required this.voucherID,
        required this.shopID,
      });

  Map<String, dynamic> toJson() => {
    'shopID': shopID,
  };

  static VoucherOfUserModel fromJson(String id, Map<String, dynamic> json) {

    return VoucherOfUserModel(
      voucherID: id,
      shopID: json['shopID'] as String,
    );
  }

}