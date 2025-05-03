import 'message_model.dart';

class ChatModel {

  String? key;
  String? userID1;
  String? userID2;
  List<MessageModel>? messages;

  static String collectionName = 'Chats';

  ChatModel({
    this.key,
    required this.userID1,
    required this.userID2,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'userID1': userID1,
    'userID2': userID2,
    'messages': (messages ?? []).map((message) => message.toJson()).toList(),
  };

  static ChatModel fromJson(String id, Map<String, dynamic> json) {
    final dataMessages = json['messages'] as List?;
    final listMessages = List.castFrom<Object?, Map<String, Object?>>(dataMessages!);

    return ChatModel(
      key: id,
      userID1: json['userID1'] as String,
      userID2: json['userID2'] as String,
      messages: listMessages.map((raw) => MessageModel.fromJson(raw)).toList(),
    );
  }
}