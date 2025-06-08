import 'package:pcplus/models/chat/message_model.dart';

abstract class ChatDetailContract {
  void onSendMessageSuccess();
  void onSendingMessage(MessageModel message);
  void onSendMessageFailed(String message);
}