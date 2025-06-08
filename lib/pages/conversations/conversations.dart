import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/component/conversation_argument.dart';
import 'package:pcplus/models/chat/message_model.dart';
import 'package:pcplus/pages/chat_detail/chat_detail.dart';
import 'package:pcplus/pages/conversations/conversations_contract.dart';
import 'package:pcplus/pages/conversations/conversations_presenter.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

import '../../controller/session_controller.dart';
import '../widgets/util_widgets.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});
  static const String routeName = 'conversations_screen';

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> implements ConversationContract {
  ConversationPresenter? _presenter;

  List<ConversationModel> conversations = [];

  @override
  void initState() {
    _presenter = ConversationPresenter(this);
    super.initState();
    // _loadMockData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    await _presenter?.getData();
  }

  // void _loadMockData() {
  //   // Mock data cho danh sách cuộc trò chuyện
  //   conversations = [
  //     ConversationModel(
  //       id: '1',
  //       participantId: 'user1',
  //       participantName: 'Nguyễn Văn A',
  //       participantAvatar:
  //           'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
  //       lastMessage: MessageModel(
  //         id: 'm1',
  //         from: 'user1',
  //         content: 'Chào bạn, sản phẩm này còn không?',
  //         time: DateTime.now().subtract(const Duration(minutes: 5)),
  //         state: MessageState.seen,
  //       ),
  //       lastActivity: DateTime.now().subtract(const Duration(minutes: 5)),
  //       unreadCount: 2,
  //     ),
  //     ConversationModel(
  //       id: '2',
  //       participantId: 'user2',
  //       participantName: 'Trần Thị B',
  //       participantAvatar:
  //           'https://images.unsplash.com/photo-1494790108755-2616b86d46c4?w=150&h=150&fit=crop&crop=face',
  //       lastMessage: MessageModel(
  //         id: 'm2',
  //         from: 'current_user',
  //         content: 'Cảm ơn bạn đã mua hàng!',
  //         time: DateTime.now().subtract(const Duration(hours: 2)),
  //         state: MessageState.sent,
  //       ),
  //       lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
  //       unreadCount: 0,
  //     ),
  //     ConversationModel(
  //       id: '3',
  //       participantId: 'user3',
  //       participantName: 'Lê Văn C',
  //       participantAvatar: null,
  //       lastMessage: MessageModel(
  //         id: 'm3',
  //         from: 'user3',
  //         content: 'Khi nào giao hàng vậy shop?',
  //         time: DateTime.now().subtract(const Duration(hours: 5)),
  //         state: MessageState.seen,
  //       ),
  //       lastActivity: DateTime.now().subtract(const Duration(hours: 5)),
  //       unreadCount: 1,
  //     ),
  //     ConversationModel(
  //       id: '4',
  //       participantId: 'user4',
  //       participantName: 'Phạm Thị D',
  //       participantAvatar:
  //           'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
  //       lastMessage: MessageModel(
  //         id: 'm4',
  //         from: 'current_user',
  //         content: 'Sản phẩm bạn cần đã hết hàng',
  //         time: DateTime.now().subtract(const Duration(days: 1)),
  //         state: MessageState.sent,
  //       ),
  //       lastActivity: DateTime.now().subtract(const Duration(days: 1)),
  //       unreadCount: 0,
  //     ),
  //   ];
  // }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tin nhắn',
          style: TextDecor.robo18Bold.copyWith(
            color: Palette.primaryColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Palette.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ConversationModel>>(
        stream: _presenter!.conversationStream,
        builder: (context, snapshot) {
          Widget? result = UtilWidgets.createSnapshotResultWidget(context, snapshot);
          if (result != null) {
            return result;
          }

          conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const Gap(24),
                  Text(
                    'Chưa có tin nhắn nào',
                    style: TextDecor.robo18Semi.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    'Bắt đầu trò chuyện với khách hàng\nhoặc người bán',
                    style: TextDecor.robo14.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return _buildConversationList();
        },
      )
    );
  }

  Widget _buildConversationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                  Palette.primaryColor.withOpacity(0.1),
                  backgroundImage: conversation.participantAvatar!.isNotEmpty
                      ? NetworkImage(conversation.participantAvatar!)
                      : null,
                  child: conversation.participantAvatar!.isEmpty
                      ? Text(
                    conversation.participantName[0].toUpperCase(),
                    style: TextDecor.robo18Semi.copyWith(
                      color: Palette.primaryColor,
                    ),
                  )
                      : null,
                ),
                if (conversation.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        conversation.unreadCount > 9
                            ? '9+'
                            : conversation.unreadCount.toString(),
                        style: TextDecor.robo11.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              conversation.participantName,
              style: TextDecor.robo16Medi.copyWith(
                fontWeight: conversation.unreadCount > 0
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(4),
                Text(
                  "${conversation.lastMessage?.from == SessionController.getInstance().userID! ? "Bạn: " : ""}${conversation.lastMessage!.content}",
                  style: TextDecor.robo14.copyWith(
                    color: conversation.unreadCount > 0
                        ? Colors.black87
                        : Colors.grey.shade600,
                    fontWeight: conversation.unreadCount > 0
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Row(
                  children: [
                    if (conversation.lastMessage?.from ==
                        SessionController.getInstance().userID!)
                      Icon(
                        conversation.lastMessage?.state ==
                            MessageState.seen
                            ? Icons.done_all
                            : Icons.done,
                        size: 16,
                        color: conversation.lastMessage?.state ==
                            MessageState.seen
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    if (conversation.lastMessage?.from ==
                        SessionController.getInstance().userID!)
                      const Gap(4),
                    Text(
                      _formatTime(conversation.lastActivity),
                      style: TextDecor.robo12.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () {
              _presenter?.handleConversationPressed(conversation);
            },
          ),
        );
      },
    );
  }

  @override
  void onConversationPressed(ConversationArgument argument) {
    // TODO: implement onConversationPressed
    Navigator.pushNamed(
      context,
      ChatDetailScreen.routeName,
      arguments: argument,
    );
  }

  @override
  void onError(String message) {
    UtilWidgets.createSnackBar(context, message, backgroundColor: Colors.red);
  }
}
