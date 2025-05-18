import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pcplus/models/users/ship_infor_model.dart';

class UserModel {
  String? userID;
  String? name;
  String? email;
  String? phone;
  DateTime? dateOfBirth;
  String? gender;
  String? userType;
  String? avatarUrl;
  ShipInformationModel? shipInformationModel;
  List<String>? fcm;
  int? money = 0;
  // Map<String, Object?>? shopInfo = {};

  static String collectionName = 'Users';
  static String cartCollectionName = 'Cart';
  static String billCollectionName = "Bills";

  UserModel({
      required this.userID,
      required this.name,
      required this.email,
      required this.phone,
      required this.dateOfBirth,
      required this.gender,
      required this.userType,
      this.shipInformationModel,
      this.avatarUrl,
      this.money,
      this.fcm,
      // this.shopInfo
  });

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'name': name,
        'email': email,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'userType': userType,
        'avatarUrl': avatarUrl,
        'shipInformation' : shipInformationModel,
        'money': money,
        'fcm': (fcm ?? []).map((key) => key).toList(),
        // 'shopInfo': jsonEncode(shopInfo)
      };

  static UserModel fromJson(Map<String, dynamic> json) {
    final dataFcm = json['fcm'] as List?;
    final listFcm = List.castFrom<Object?, Map<String, Object?>>(dataFcm!);

    DateTime? dateTime;
    if (json['dateOfBirth'] is Timestamp == false) {
      dateTime = DateTime.parse(json['dateOfBirth']);
    }

    return UserModel(
        userID: json['userID'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        dateOfBirth: dateTime ?? (json['dateOfBirth'] as Timestamp).toDate(),
        gender: json['gender'] as String,
        userType: json['userType'] as String,
        avatarUrl: json['avatarUrl'] as String,
        shipInformationModel: ShipInformationModel.fromJson(json['shipInformation']),
        money: (json['money'] ?? 0) as int,
        fcm: listFcm.map((raw) => raw as String).toList()
        // shopInfo: shopInfo
    );
  }
}

abstract class UserType {
  static const USER = "user";
  static const SHOP = "shop";
  static const SHIPPER = "shipper";
  static const ADMIN = "admin";
}