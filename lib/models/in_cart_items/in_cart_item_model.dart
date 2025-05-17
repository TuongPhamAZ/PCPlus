
import '../items/color_model.dart';

class InCartItemModel {

  String? key;
  String? itemID;
  int? amount;
  ColorModel? color;
  bool? isSelected;

  InCartItemModel(
      {
        this.key,
        required this.itemID,
        required this.amount,
        this.color,
        this.isSelected,
      });

  static String collectionName = 'InCartItems';

  Map<String, dynamic> toJson() => {
    'itemID': itemID,
    'amount': amount,
    'color': color?.toJson(),
    'isSelected': isSelected,
  };

  static InCartItemModel fromJson(String key, Map<String, dynamic> json) {

    return InCartItemModel(
      key: key,
      itemID: json['itemID'] as String,
      amount: json['amount'] as int,
      color: ColorModel.fromJson(json['color']),
      isSelected: json['isSelected'] as bool,
    );
  }

}