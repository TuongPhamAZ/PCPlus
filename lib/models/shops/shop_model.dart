class ShopModel {
  String? shopID;
  String? name;
  String? location;
  String? phone;
  double? rating;
  int? ratingCount;
  String? image;

  static String collectionName = 'Shops';
  static String billCollectionName = "Bills";

  ShopModel({
    required this.shopID,
    required this.name,
    required this.location,
    required this.phone,
    required this.rating,
    this.ratingCount,
    this.image,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'location': location,
    'phone': phone,
    'rating': rating,
    'image': image,
    'ratingCount': ratingCount ?? 0,
  };

  static ShopModel fromJson(String id, Map<String, dynamic> json) {

    return ShopModel(
      shopID: id,
      name: json['name'] as String,
      location: json['location'] as String,
      phone: json['phone'] as String,
      rating: (json['rating'] ?? 0.0) as double,
      image: json['image'] as String,
      ratingCount: (json['ratingCount'] ?? 0) as int,
    );
  }

}