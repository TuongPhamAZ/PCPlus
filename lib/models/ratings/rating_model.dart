import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {

  String? key;
  String? userID;
  String? itemID;
  double? rating;
  DateTime? date;
  String? comment;
  List<String>? like;
  List<String>? dislike;
  String? response;

  static String collectionName = 'Ratings';

  RatingModel({
    this.key,
    required this.userID,
    required this.itemID,
    required this.rating,
    required this.date,
    this.comment,
    required this.like,
    required this.dislike,
    this.response,
  });

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'itemID': itemID,
    'rating': rating,
    'comment': comment,
    'date': date,
    'like': (like ?? []).toList(),
    'dislike': (dislike ?? []).toList(),
    'response': response,
  };

  static RatingModel fromJson(String key, Map<String, dynamic> json) {
    final dataLikes = json['like'] as List?;
    final listLikes = List.castFrom<Object?, Map<String, Object?>>(dataLikes!);
    final dataDislikes = json['dislike'] as List?;
    final listDislikes = List.castFrom<Object?, Map<String, Object?>>(dataDislikes!);

    return RatingModel(
        key: key,
        userID: json['userID'] as String,
        itemID: json['itemID'] as String,
        rating: json['rating'] as double,
        comment: json['comment'] as String,
        date: (json['date'] as Timestamp).toDate(),
        like: listLikes.map((raw) => raw as String).toList(),
        dislike: listDislikes.map((raw) => raw as String).toList(),
        response: (json['response'] ?? "") as String
    );
  }
}