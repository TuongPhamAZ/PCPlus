import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? key;
  String? title;
  String? content;
  DateTime? date;
  bool? isRead;
  String? productImage;

  static String collectionName = 'Notifications';

  NotificationModel({
    this.key,
    required this.title,
    required this.content,
    required this.date,
    required this.isRead,
    required this.productImage
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'date': date,
        'isRead': isRead,
        'productImage': productImage
      };

  static NotificationModel fromJson(String key, Map<String, dynamic> json) {
    return NotificationModel(
      key: key,
      title: json['title'] as String,
      content: json['content'] as String,
      date: (json['date'] as Timestamp).toDate(),
      isRead: json['isRead'] as bool,
      productImage: json['productImage'] as String
    );
  }
}
