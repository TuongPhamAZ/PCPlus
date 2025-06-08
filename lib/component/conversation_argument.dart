import 'package:pcplus/models/chat/message_model.dart';

class ConversationArgument {
  final ConversationModel ownerConversation;
  final ConversationModel? partnerConversation;

  ConversationArgument({
    required this.ownerConversation,
    required this.partnerConversation,
  });
}