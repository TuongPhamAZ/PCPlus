
class InCartItemModel {

  String? key;
  String? itemID;
  int? amount;
  String? color;

  InCartItemModel(
      {
        this.key,
        required this.itemID,
        required this.amount,
        this.color,
      });

  static String collectionName = 'InCartItems';

  Map<String, dynamic> toJson() => {
    'itemID': itemID,
    'amount': amount,
    'color': color,
  };

  static InCartItemModel fromJson(String key, Map<String, dynamic> json) {

    return InCartItemModel(
      key: key,
      itemID: json['itemID'] as String,
      amount: json['amount'] as int,
      color: json['color'] as String,
    );
  }

}