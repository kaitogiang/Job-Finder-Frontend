import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/conversation.dart';
import 'package:job_finder_app/models/message.dart';
import 'package:job_finder_app/ui/shared/message_manager.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  // ScrollController để điều khiển việc cuộn trong SingleChildScrollView
  // initialScrollOffset được đặt bằng BouncingScrollSimulation.maxSpringTransferVelocity
  // để bắt đầu cuộn từ vị trí cao nhất tức là bên dưới (bottom)
  final ScrollController _scrollController = ScrollController(
      initialScrollOffset: BouncingScrollSimulation.maxSpringTransferVelocity);
  ValueNotifier<bool> _isScrolledToBottom =
      ValueNotifier(true); //Biến kiểm tra xem đã scroll đến bottom chưa?
  final isEmployer = false;
  //Khởi tạo dữ liệu
  late Conversation conversation;

  final ValueNotifier<EdgeInsets> _bottomPadding =
      ValueNotifier(EdgeInsets.zero);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      double currentScrollPosiion = _scrollController.offset;
      // Utils.logMessage('currentScrollPosiion: $currentScrollPosiion');
      if (currentScrollPosiion <= maxScrollExtent - 200) {
        _isScrolledToBottom.value = false;
      } else {
        _isScrolledToBottom.value = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_searchController.text.isNotEmpty) {
      // Gửi tin nhắn
      String message = _searchController.text;
      _searchController.clear();
      Utils.logMessage('Sent message: $message');
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Utils.logMessage('didChangeDependencies ChatScreen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceSize = MediaQuery.of(context).size;
    conversation =
        context.watch<MessageManager>().getConversation(widget.conversationId);
    // Lắng nghe thay đổi từ bàn phím
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    Utils.logMessage('Rebult ChatScreen');
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: 70,
          leading: IconButton(
            onPressed: () {
              // context.pop();
              GoRouter.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          flexibleSpace: Container(
            width: deviceSize.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.blueAccent.shade700,
                  Colors.blueAccent.shade400,
                  theme.primaryColor,
                ],
              ),
            ),
          ),
          title: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 0),
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(conversation.opponent.avatar),
            ),
            title: Text(
              '${conversation.opponent.firstName} ${conversation.opponent.lastName}',
              style: textTheme.bodyLarge!.copyWith(
                color: theme.indicatorColor,
              ),
            ),
            subtitle: RichText(
              text: TextSpan(
                children: [
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.circle,
                      color: Colors.green,
                      size: 10,
                    ),
                  ),
                  const WidgetSpan(
                    child: SizedBox(
                      width: 5,
                    ),
                  ),
                  TextSpan(
                    text: 'Đang hoạt động',
                    style: textTheme.bodySmall!.copyWith(
                      color: Colors.grey[300],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          titleSpacing: 0,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 13, right: 13, bottom: 10),
                child: Column(
                  children: List<Widget>.generate(
                    conversation.messages.length,
                    (index) {
                      final message = conversation.messages[index] as Message;
                      final messageDate = message.timestamp;
                      final previousMessageDate = index > 0
                          ? conversation.messages[index - 1].timestamp
                          : null;
                      final showDateLabel = previousMessageDate == null ||
                          messageDate.day != previousMessageDate.day;
                      final isLastInSequence =
                          index == conversation.messages.length - 1 ||
                              message.senderId !=
                                  conversation.messages[index + 1].senderId;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateLabel)
                            Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 8),
                              child: Center(
                                child: Text(
                                  DateFormat('HH:mm dd/MM/yyyy')
                                      .format(messageDate),
                                  style: textTheme.bodySmall,
                                ),
                              ),
                            ),
                          _buildMessageWidget(message, index, isEmployer)
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: _isScrolledToBottom,
              builder: (context, isScrolledToBottom, child) {
                if (isScrolledToBottom) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      alignment: Alignment.bottomCenter,
                      onPressed: _scrollToBottom,
                      icon: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.arrow_downward_rounded,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: AnimatedPadding(
          padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 0),
          duration: const Duration(milliseconds: 0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onTap: () {},
                  decoration: const InputDecoration(
                    constraints: BoxConstraints.tightFor(height: 60),
                    hintText: 'Tin nhắn',
                    prefixIcon: Icon(Icons.message),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (value) {
                    _sendMessage();
                  },
                ),
              ),
              IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send))
            ],
          ),
        ),
      );
    });
  }

  // Hàm xây dựng widget tin nhắn
  Widget _buildMessageWidget(Message message, int index, bool isEmployer) {
    // Kiểm tra xem tin nhắn có phải của người dùng hiện tại không
    final isMyMessage = (isEmployer && message.senderId == 'user2_id') ||
        (!isEmployer && message.senderId == 'user1_id');
    // Kiểm tra xem tin nhắn có liền mạch với tin nhắn trước đó không
    final isSeamlessMessages = index > 0 &&
        message.senderId == conversation.messages[index - 1].senderId;
    // Kiểm tra xem tin nhắn có phải là tin nhắn cuối cùng trong chuỗi không
    final isLastInSequence = index == conversation.messages.length - 1 ||
        message.senderId != conversation.messages[index + 1].senderId;
    // Đường dẫn avatar của người gửi tin nhắn
    final avatarLink = conversation.opponent.avatar;

    // Nếu là tin nhắn của người dùng hiện tại
    if (isMyMessage) {
      return MyMessages(
        message: message.messageText, // Nội dung tin nhắn
        timestamp: message.timestamp, // Thời gian gửi tin nhắn
        isLastInSequence: isLastInSequence, // Tin nhắn cuối cùng trong chuỗi
      );
    } else {
      // Nếu là tin nhắn của đối phương
      return OpponentMessages(
        message: message.messageText, // Nội dung tin nhắn
        timestamp: message.timestamp, // Thời gian gửi tin nhắn
        isSeamlessMessages: isSeamlessMessages, // Tin nhắn liền mạch
        isLastInSequence: isLastInSequence, // Tin nhắn cuối cùng trong chuỗi
        avatarLink: avatarLink, // Đường dẫn avatar của đối phương
      );
    }
  }
}

class MyMessages extends StatelessWidget {
  const MyMessages({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isLastInSequence,
  });

  final String message;
  final DateTime timestamp;
  final bool isLastInSequence;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: deviceSize.width * 0.7,
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  if (isLastInSequence)
                    Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: textTheme.bodySmall!.copyWith(
                        color: Colors.grey[300],
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OpponentMessages extends StatelessWidget {
  const OpponentMessages({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isSeamlessMessages,
    required this.isLastInSequence,
    required this.avatarLink,
  });

  final String message;
  final DateTime timestamp;
  final bool isSeamlessMessages;
  final bool isLastInSequence;
  final String avatarLink;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSeamlessMessages)
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(avatarLink),
            ),
          SizedBox(
            width: !isSeamlessMessages
                ? 10
                : 40, //40 đối với tin nhắn trước đó là của đối tác và họ nhắn tiếp
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: deviceSize.width * 0.7,
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                  ),
                  if (isLastInSequence)
                    Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: textTheme.bodySmall!.copyWith(
                        color: Colors.grey,
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
