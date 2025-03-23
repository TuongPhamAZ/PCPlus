class SaleItemModel {

  String? key;
  String? saleID;
  String? itemID;

  static String collectionName = 'SalesItems';

  SaleItemModel({
    required this.key,
    required this.saleID,
    required this.itemID
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'saleID': saleID,
    'itemID': itemID,
  };

  static SaleItemModel fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      key: json['key'] as String,
      saleID: json['saleID'] as String,
      itemID: json['itemID'] as String,
    );
  }
}