class ParamStoreModel {

  int orderIdIndex;

  ParamStoreModel({
    required this.orderIdIndex,
  });

  Map<String, dynamic> toJson() => {
    'orderIdIndex': orderIdIndex,
  };

  static ParamStoreModel fromJson(Map<String, dynamic> json) {
    return ParamStoreModel(
      orderIdIndex: json['orderIdIndex'] as int,
    );
  }
}