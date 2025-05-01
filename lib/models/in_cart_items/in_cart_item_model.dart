
import '../items/color_model.dart';

class InCartItemModel {

  String? key;
  String? itemID;
  int? amount;
  ColorModel? color;
  bool? isSelected;
  String? noteForShop = "";
  String? deliveryMethod = "";
  int? deliveryCost = 0;

  InCartItemModel(
      {
        this.key,
        required this.itemID,
        required this.amount,
        this.color,
        this.isSelected,
        this.noteForShop,
        this.deliveryMethod,
        this.deliveryCost,
      });

  static String collectionName = 'InCartItems';

  Map<String, dynamic> toJson() => {
    'itemID': itemID,
    'amount': amount,
    'color': color,
    'isSelected': isSelected,
    'noteForShop': noteForShop ?? "",
    'deliveryMethod': deliveryMethod ?? "",
    'deliveryCost': deliveryCost ?? "",
  };

  static InCartItemModel fromJson(String key, Map<String, dynamic> json) {

    return InCartItemModel(
      key: key,
      itemID: json['itemID'] as String,
      amount: json['amount'] as int,
      color: ColorModel.fromJson(json['color']),
      isSelected: json['isSelected'] as bool,
      noteForShop: (json['noteForShop'] ?? "") as String,
      deliveryMethod: (json['deliveryMethod'] ?? "") as String,
      deliveryCost:  (json['deliveryCost'] ?? 0) as int,
    );
  }

}