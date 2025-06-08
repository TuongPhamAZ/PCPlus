import 'package:pcplus/component/conversation_argument.dart';

abstract class ConversationContract {
  void onConversationPressed(ConversationArgument argument);
  void onError(String message);
}