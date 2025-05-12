import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/conversation.dart';
import 'package:job_finder_app/models/message.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
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
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final _isScrolledToBottom = ValueNotifier(true);

  late Conversation _conversation;
  late MessageManager _messageManager;
  late bool _isEmployer;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    _initializeUserData();
    _setupMessageHandling();
  }

  void _setupScrollController() {
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final position = _scrollController.offset;
    _isScrolledToBottom.value = position >= _scrollController.position.maxScrollExtent - 200;
  }

  void _initializeUserData() {
    _isEmployer = context.read<AuthManager>().isEmployer;
    _userId = context.read<AuthManager>().authToken!.userId;
  }

  void _setupMessageHandling() {
    context.read<MessageManager>().joinConversation(widget.conversationId);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animate: false);
      _messageManager = context.read<MessageManager>();
      _markMessagesAsRead();
    });
  }

  void _markMessagesAsRead() {
    final hasUnreadMessages = (_isEmployer && _messageManager.unseenEmployerMessages > 0) ||
                            (!_isEmployer && _messageManager.unseenJobseekerMessages > 0);
    
    if (hasUnreadMessages) {
      _messageManager.readMessages(widget.conversationId, _userId, _isEmployer);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _messageManager.leaveConversation(widget.conversationId);
    super.dispose();
  }

  void _sendMessage() {
    final messageText = _textController.text;
    if (messageText.isEmpty) return;

    final senderIsJobseeker = !_isEmployer;
    _messageManager.sendMessage(widget.conversationId, messageText, senderIsJobseeker);
    
    _textController.clear();
    Utils.logMessage('Sent message: $messageText');
    _scrollToBottom();
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position.maxScrollExtent;
    
    if (animate) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(position);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Utils.logMessage('didChangeDependencies ChatScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animate: false));
  }

  @override
  Widget build(BuildContext context) {
    Utils.logMessage('IsEmployer: $_isEmployer');
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceSize = MediaQuery.of(context).size;
    
    _conversation = context.watch<MessageManager>().getConversation(widget.conversationId);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(theme, textTheme, deviceSize),
          body: Column(
            children: [
              Expanded(
                child: _buildMessageList(textTheme),
              ),
              _buildMessageInput(),
            ],
          ),
        );
      }
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, TextTheme textTheme, Size deviceSize) {
    return AppBar(
      toolbarHeight: 70,
      leading: IconButton(
        onPressed: () => GoRouter.of(context).pop(),
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
      title: _buildUserInfo(theme, textTheme),
      titleSpacing: 0,
    );
  }

  Widget _buildUserInfo(ThemeData theme, TextTheme textTheme) {
    final otherUser = _isEmployer ? _conversation.jobseeker : _conversation.employer;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(otherUser.getImageUrl()),
      ),
      title: Text(
        '${otherUser.firstName} ${otherUser.lastName}',
        style: textTheme.bodyLarge!.copyWith(color: theme.indicatorColor),
      ),
      subtitle: _buildOnlineStatus(textTheme),
    );
  }

  Widget _buildOnlineStatus(TextTheme textTheme) {
    return RichText(
      text: TextSpan(
        children: [
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(Icons.circle, color: Colors.green, size: 10),
          ),
          const WidgetSpan(child: SizedBox(width: 5)),
          TextSpan(
            text: 'Đang hoạt động',
            style: textTheme.bodySmall!.copyWith(
              color: Colors.grey[300],
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(TextTheme textTheme) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(13),
          child: GestureDetector(
            onTap: () => _focusNode.unfocus(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _conversation.messages.length,
              itemBuilder: (context, index) => _buildMessageItem(index, textTheme),
            ),
          ),
        ),
        _buildScrollToBottomButton(),
      ],
    );
  }

  Widget _buildMessageItem(int index, TextTheme textTheme) {
    final message = _conversation.messages[index];
    final previousMessage = index > 0 ? _conversation.messages[index - 1] : null;
    final showDateLabel = _shouldShowDateLabel(message.timestamp, previousMessage?.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDateLabel)
          _buildDateLabel(message.timestamp, textTheme),
        _buildMessageWidget(message, index),
      ],
    );
  }

  bool _shouldShowDateLabel(DateTime messageDate, DateTime? previousDate) {
    return previousDate == null || messageDate.day != previousDate.day;
  }

  Widget _buildDateLabel(DateTime date, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          DateFormat('HH:mm dd/MM/yyyy').format(date),
          style: textTheme.bodySmall,
        ),
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return ValueListenableBuilder(
      valueListenable: _isScrolledToBottom,
      builder: (context, isScrolledToBottom, _) {
        if (isScrolledToBottom) return const SizedBox.shrink();

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: IconButton(
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
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              constraints: BoxConstraints.tightFor(height: 60),
              hintText: 'Tin nhắn',
              prefixIcon: Icon(Icons.message),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) {
              _sendMessage();
              _focusNode.requestFocus();
            },
          ),
        ),
        IconButton(
          onPressed: _sendMessage,
          icon: const Icon(Icons.send),
        ),
      ],
    );
  }

  Widget _buildMessageWidget(Message message, int index) {
    final isMyMessage = (_isEmployer && message.senderId == _conversation.employer.id) ||
                       (!_isEmployer && message.senderId == _conversation.jobseeker.id);
    final isSeamlessMessages = index > 0 && message.senderId == _conversation.messages[index - 1].senderId;
    final isLastInSequence = index == _conversation.messages.length - 1 ||
                            message.senderId != _conversation.messages[index + 1].senderId;
    final avatarLink = _isEmployer ? _conversation.jobseeker.getImageUrl() : _conversation.employer.getImageUrl();

    if (isMyMessage) {
      return MyMessages(
        message: message.messageText,
        timestamp: message.timestamp,
        isLastInSequence: isLastInSequence,
      );
    } else {
      return OpponentMessages(
        message: message.messageText,
        timestamp: message.timestamp,
        isSeamlessMessages: isSeamlessMessages,
        isLastInSequence: isLastInSequence,
        avatarLink: avatarLink,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
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
            width: !isSeamlessMessages ? 10 : 40,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: deviceSize.width * 0.7,
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message),
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
