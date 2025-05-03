class ColorModel {

  String? name;
  String? image;

  ColorModel(
      {
        required this.name,
        required this.image,
        // required this.voucherModel,
      });

  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    // 'voucher': voucher,
  };

  static ColorModel fromJson(Map<String, dynamic> json) {

    return ColorModel(
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }
}