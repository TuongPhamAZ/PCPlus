import 'package:pcplus/component/conversation_argument.dart';
import 'package:pcplus/controller/session_controller.dart';
import 'package:pcplus/models/chat/conversation_repo.dart';
import 'package:pcplus/models/chat/message_model.dart';
import 'package:pcplus/pages/conversations/conversations_contract.dart';

class ConversationPresenter {
  final ConversationContract _view;
  ConversationPresenter(this._view);

  final ConversationRepository _conversationRepo = ConversationRepository();
  final SessionController _sessionController = SessionController.getInstance();

  Stream<List<ConversationModel>>? conversationStream;

  Future<void> getData() async {
    conversationStream = _conversationRepo.getAllConversationStream(_sessionController.userID!);
  }

  Future<void> handleConversationPressed(ConversationModel conversation) async {
    ConversationModel? otherConversation = await _conversationRepo.getConversation(conversation.participantId, _sessionController.userID!);

    if (otherConversation == null) {
      _view.onError('Đã có lỗi xảy ra. Vui lòng thử lại sau.');
      return;
    }

    ConversationArgument argument = ConversationArgument(
        ownerConversation: conversation,
        partnerConversation: otherConversation
    );

    _view.onConversationPressed(argument);
  }
}