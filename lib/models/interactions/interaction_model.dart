class InteractionModel {

  String? key;
  String? userID;
  String? itemID;
  int? clickTimes;
  int? buyTimes;
  double? rating;
  bool? isFavor;

  static String collectionName = 'Interactions';

  InteractionModel({
    this.key,
    required this.userID,
    required this.itemID,
    required this.clickTimes,
    required this.buyTimes,
    required this.rating,
    required this.isFavor,
  });

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'itemID': itemID,
    'clickTimes': clickTimes,
    'buyTimes': buyTimes,
    'rating': rating,
    'isFavor': isFavor
  };

  static InteractionModel fromJson(String id, Map<String, dynamic> json) {
    return InteractionModel(
      key: id,
      userID: json['userID'] as String,
      itemID: json['itemID'] as String,
      clickTimes: json['clickTimes'] as int,
      buyTimes: json['buyTimes'] as int,
      rating: json['rating'] as double,
      isFavor: json['isFavor'] as bool
    );
  }
}