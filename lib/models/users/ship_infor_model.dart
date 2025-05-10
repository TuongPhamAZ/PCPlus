class ShipInformationModel {

  String? receiverName;
  String? location;
  String? phone;
  bool? isDefault;

  ShipInformationModel(
      {
        required this.receiverName,
        required this.location,
        required this.phone,
        required this.isDefault,
      });

  Map<String, dynamic> toJson() => {
    'receiverName': receiverName,
    'location': location,
    'phone': phone,
    'isDefault': isDefault,
  };

  static ShipInformationModel? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return ShipInformationModel(
      receiverName: json['receiverName'] as String,
      location: json['location'] as String,
      phone: json['phone'] as String,
      isDefault: json['isDefault'] as bool,
    );
  }
}