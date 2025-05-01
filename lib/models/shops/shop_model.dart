class ShopModel {
  String? shopID;
  String? name;
  String? location;
  String? phone;
  double? rating;
  String? image;

  static String collectionName = 'Shops';
  static String billCollectionName = "Bills";

  ShopModel({
    required this.shopID,
    required this.name,
    required this.location,
    required this.phone,
    required this.rating,
    this.image,
  });

  Map<String, dynamic> toJson() => {
    'shopID': shopID,
    'name': name,
    'location': location,
    'phone': phone,
    'rating': rating,
    'image': image,
  };

  static ShopModel fromJson(Map<String, dynamic> json) {

    return ShopModel(
      shopID: json['shopID'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      phone: json['phone'] as String,
      rating: (json['rating']) as double,
      image: json['image'] as String,
    );
  }

}