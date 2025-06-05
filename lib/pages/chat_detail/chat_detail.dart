import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pcplus/models/chat/message_model.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class ChatDetailScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatDetailScreen({super.key, required this.conversation});
  static const String routeName = 'chat_detail_screen';

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<MessageModel> messages = [];
  final String currentUserId = 'current_user'; // ID của user hiện tại

  @override
  void initState() {
    super.initState();

    // Debug: In ra thông tin conversation để kiểm tra
    print(
        'ChatDetail: participantName = ${widget.conversation.participantName}');
    print(
        'ChatDetail: participantAvatar = ${widget.conversation.participantAvatar}');

    _loadMockMessages();
  }

  void _loadMockMessages() {
    // Mock data cho tin nhắn
    messages = [
      MessageModel(
        id: 'msg1',
        from: widget.conversation.participantId,
        content: 'Chào bạn!',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        state: MessageState.seen,
      ),
      MessageModel(
        id: 'msg2',
        from: currentUserId,
        content: 'Chào bạn, tôi có thể giúp gì cho bạn?',
        time: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
        state: MessageState.seen,
      ),
      MessageModel(
        id: 'msg3',
        from: widget.conversation.participantId,
        content: 'Sản phẩm này còn hàng không ạ?',
        time: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        state: MessageState.seen,
      ),
      MessageModel(
        id: 'msg4',
        from: currentUserId,
        content: 'Vẫn còn hàng bạn ạ. Bạn cần bao nhiều?',
        time: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
        state: MessageState.seen,
      ),
      MessageModel(
        id: 'msg5',
        from: widget.conversation.participantId,
        content: 'Mình cần 2 cái. Giá như thế nào?',
        time: DateTime.now().subtract(const Duration(minutes: 30)),
        state: MessageState.seen,
      ),
      MessageModel(
        id: 'msg6',
        from: currentUserId,
        content:
            'Giá là 500k/cái bạn ạ. 2 cái là 1 triệu. Bạn có muốn đặt không?',
        time: DateTime.now().subtract(const Duration(minutes: 25)),
        state: MessageState.sent,
      ),
    ];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      from: currentUserId,
      content: _messageController.text.trim(),
      time: DateTime.now(),
      state: MessageState.sending,
    );

    setState(() {
      messages.add(newMessage);
      _messageController.clear();
    });

    // Cuộn xuống tin nhắn mới nhất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate message sent after delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          final index = messages.indexWhere((msg) => msg.id == newMessage.id);
          if (index != -1) {
            messages[index] = MessageModel(
              id: newMessage.id,
              from: newMessage.from,
              content: newMessage.content,
              time: newMessage.time,
              state: MessageState.sent,
            );
          }
        });
      }
    });
  }

  Widget _buildMessage(MessageModel message, bool isMe) {
    // Kiểm tra avatar có hợp lệ không (không null và không empty)
    final hasValidAvatar = widget.conversation.participantAvatar != null &&
        widget.conversation.participantAvatar!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Palette.primaryColor.withOpacity(0.1),
              backgroundImage: hasValidAvatar
                  ? NetworkImage(widget.conversation.participantAvatar!)
                  : null,
              child: !hasValidAvatar
                  ? Text(
                      widget.conversation.participantName[0].toUpperCase(),
                      style: TextDecor.robo12.copyWith(
                        color: Palette.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const Gap(8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? Palette.primaryColor : Colors.grey.shade200,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextDecor.robo14.copyWith(
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const Gap(4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.time),
                      style: TextDecor.robo11.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (isMe) ...[
                      const Gap(4),
                      Icon(
                        message.state == MessageState.sending
                            ? Icons.access_time
                            : message.state == MessageState.sent
                                ? Icons.done
                                : Icons.done_all,
                        size: 14,
                        color: message.state == MessageState.seen
                            ? Colors.blue
                            : Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: TextDecor.robo12.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra avatar có hợp lệ không (không null và không empty)
    final hasValidAvatar = widget.conversation.participantAvatar != null &&
        widget.conversation.participantAvatar!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Palette.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Palette.primaryColor.withOpacity(0.1),
              backgroundImage: hasValidAvatar
                  ? NetworkImage(widget.conversation.participantAvatar!)
                  : null,
              child: !hasValidAvatar
                  ? Text(
                      widget.conversation.participantName[0].toUpperCase(),
                      style: TextDecor.robo16Medi.copyWith(
                        color: Palette.primaryColor,
                      ),
                    )
                  : null,
            ),
            const Gap(12),
            Expanded(
              child: Text(
                widget.conversation.participantName,
                style: TextDecor.robo16Medi.copyWith(
                  color: Palette.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.from == currentUserId;

                // Kiểm tra xem có cần hiển thị date separator không
                bool showDateSeparator = false;
                if (index == 0) {
                  showDateSeparator = true;
                } else {
                  final previousMessage = messages[index - 1];
                  final currentDate = DateTime(
                      message.time.year, message.time.month, message.time.day);
                  final previousDate = DateTime(previousMessage.time.year,
                      previousMessage.time.month, previousMessage.time.day);
                  showDateSeparator = !currentDate.isAtSameDay(previousDate);
                }

                return Column(
                  children: [
                    if (showDateSeparator) _buildDateSeparator(message.time),
                    _buildMessage(message, isMe),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          hintStyle: TextDecor.robo14.copyWith(
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Container(
                    decoration: BoxDecoration(
                      color: Palette.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

extension DateTimeExtension on DateTime {
  bool isAtSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
