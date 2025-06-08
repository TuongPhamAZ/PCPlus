import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/chat/conversation_repo.dart';
import 'package:pcplus/models/chat/message_model.dart';
import 'package:pcplus/models/chat/message_repo.dart';
import 'package:pcplus/pages/chat_detail/chat_detail_contract.dart';

class ChatDetailPresenter {
  final ChatDetailContract _view;

  ChatDetailPresenter(this._view);

  final MessageRepository _messageRepo = MessageRepository();
  final SessionController _sessionController = SessionController.getInstance();
  final ConversationRepository _conversationRepo = ConversationRepository();

  ConversationModel? conversationModel;
  ConversationModel? otherConversation;

  Stream<List<MessageModel>>? messageStream;

  Future<void> getData() async {
    messageStream = _messageRepo.getAllMessagesStream(_sessionController.userID!, conversationModel!.id);
  }

  Future<void> handleReadMessage(List<MessageModel> messages) async {
    for (MessageModel messageModel in messages) {
      if (messageModel.from != _sessionController.userID! && messageModel.state == MessageState.sent) {
        messageModel.state = MessageState.seen;
        await _messageRepo.updateMessage(_sessionController.userID!, conversationModel!.id, messageModel);
        if (otherConversation != null) {
          await _messageRepo.updateMessage(conversationModel!.participantId, otherConversation!.id, messageModel);
        }
      }
    }
    conversationModel!.unreadCount = 0;
    await _conversationRepo.updateConversation(_sessionController.userID!, conversationModel!);
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) {
      return;
    }

    MessageModel newMessage = MessageModel(
        from: _sessionController.userID!,
        content: message,
        time: DateTime.now(),
        state: MessageState.sending,
    );

    _view.onSendingMessage(newMessage);

    newMessage.state = MessageState.sent;

    if (otherConversation == null) {
      // Thêm luôn conversation của user
      await _conversationRepo.addConversationToFirestore(_sessionController.userID!, conversationModel!);
    }

    String? messageID = await _messageRepo.addMessageToFirestore(_sessionController.userID!, conversationModel!.id, newMessage);

    newMessage.id = messageID;

    // Đối phương chưa có conversation (trường hợp này chỉ có đối phương là shop, cho nên không cần xét thêm case khác)
    if (otherConversation == null) {
      otherConversation = ConversationModel(
          id: _sessionController.userID!,
          participantId: _sessionController.userID!,
          participantName: _sessionController.currentUser!.name!,
          lastActivity: newMessage.time,
          lastMessage: newMessage,
          participantAvatar: _sessionController.currentUser!.avatarUrl,
          unreadCount: 0,
      );

      await _conversationRepo.addConversationToFirestore(conversationModel!.participantId, otherConversation!);
    }

    await _messageRepo.addMessageToFirestore(conversationModel!.participantId, otherConversation!.id, newMessage);

    conversationModel!.lastMessage = newMessage;
    otherConversation!.lastMessage = newMessage;
    conversationModel!.lastActivity = newMessage.time;
    otherConversation!.lastActivity = newMessage.time;
    otherConversation!.unreadCount = otherConversation!.unreadCount + 1;

    await _conversationRepo.updateConversation(_sessionController.userID!, conversationModel!);
    await _conversationRepo.updateConversation(conversationModel!.participantId, otherConversation!);
  }
}