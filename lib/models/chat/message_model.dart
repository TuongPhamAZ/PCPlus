class MessageModel {
  final String id;
  final String from; // userID của người gửi
  final String content; // nội dung tin nhắn
  final DateTime time; // thời gian gửi
  final MessageState state; // trạng thái tin nhắn

  MessageModel({
    required this.id,
    required this.from,
    required this.content,
    required this.time,
    required this.state,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'content': content,
      'time': time.millisecondsSinceEpoch,
      'state': state.toString(),
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      from: json['from'],
      content: json['content'],
      time: DateTime.fromMillisecondsSinceEpoch(json['time']),
      state: MessageState.values.firstWhere(
        (e) => e.toString() == json['state'],
        orElse: () => MessageState.sent,
      ),
    );
  }
}

enum MessageState {
  sending, // đang gửi
  sent, // đã gửi
  seen, // đã xem
}

class ConversationModel {
  final String id;
  final String participantId; // ID của người còn lại trong cuộc trò chuyện
  final String participantName; // tên của người còn lại
  final String? participantAvatar; // avatar của người còn lại
  final MessageModel? lastMessage; // tin nhắn cuối cùng
  final DateTime lastActivity; // thời gian hoạt động cuối
  final int unreadCount; // số tin nhắn chưa đọc

  ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    this.lastMessage,
    required this.lastActivity,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantId': participantId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
      'lastMessage': lastMessage?.toJson(),
      'lastActivity': lastActivity.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
    };
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participantId: json['participantId'],
      participantName: json['participantName'],
      participantAvatar: json['participantAvatar'],
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      lastActivity: DateTime.fromMillisecondsSinceEpoch(json['lastActivity']),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
