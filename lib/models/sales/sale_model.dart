class SaleModel {

  String? saleID;
  int? saleRate;
  DateTime? startDate;
  DateTime? endDate;
  String? description;
  bool? isDeleted = false;

  static String collectionName = 'Sales';

  SaleModel({
    required this.saleID,
    required this.saleRate,
    required this.startDate,
    required this.endDate,
    this.description,
    this.isDeleted
  });

  Map<String, dynamic> toJson() => {
    'saleID': saleID,
    'saleRate': saleRate,
    'startDate': startDate,
    'endDate': endDate,
    'description': description,
    'isDeleted': isDeleted
  };

  static SaleModel fromJson(Map<String, dynamic> json) {
    return SaleModel(
      saleID: json['saleID'] as String,
      saleRate: json['saleRate'] as int,
      startDate: json['startDate'] as DateTime,
      endDate: json['endDate'] as DateTime,
      description: json['description'] as String,
      isDeleted: json['isDeleted'] as bool
    );
  }
}