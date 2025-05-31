// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {

  String? userID;
  String? content;
  DateTime? time;
  String? state;

  MessageModel({
    required this.userID,
    required this.content,
    required this.time,
    required this.state,
  });

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'content': content,
    'time': time,
    'state': state,
  };

  static MessageModel fromJson(Map<String, dynamic> json) {

    return MessageModel(
      userID: json['userID'] as String,
      content: json['content'] as String,
      time: (json['time'] as Timestamp).toDate(),
      state: json['state'] as String,
    );
  }
}

class MessageState {
  static const String READ = "read";
  static const String UNREAD = "unread";
}