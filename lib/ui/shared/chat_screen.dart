import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
      ValueNotifier(false); //Biến kiểm tra xem đã scroll đến bottom chưa?
  final isEmployer = false;

  final messages = [
    {
      "_id": "message_1",
      "conversationId": "12345", // ID của cuộc hội thoại
      "senderId": "user1_id", // ID của người gửi
      "receiverId": "user2_id", // ID của người nhận
      "messageText": "Hello, how are you?", // Nội dung tin nhắn
      "timestamp": "2024-09-05T10:00:00Z", // Thời gian tin nhắn được gửi
      "isRead": false // Tin nhắn chưa đọc
    },
    {
      "_id": "message_2",
      "conversationId": "12345", // ID của cuộc hội thoại
      "senderId": "user2_id", // ID của người gửi
      "receiverId": "user1_id", // ID của người nhận
      "messageText": "I'm good, thanks! What about you?", // Nội dung tin nhắn
      "timestamp": "2024-09-05T10:01:00Z", // Thời gian tin nhắn được gửi
      "isRead": false // Tin nhắn chưa đọc
    },
    // {
    //   "_id": "message_3",
    //   "conversationId": "12345", // ID của cuộc hội thoại
    //   "senderId": "user1_id", // ID của người gửi
    //   "receiverId": "user2_id", // ID của người nhận
    //   "messageText":
    //       "I'm doing great too. Any plans for today?", // Nội dung tin nhắn
    //   "timestamp": "2024-09-05T10:02:00Z", // Thời gian tin nhắn được gửi
    //   "isRead": false // Tin nhắn chưa đọc
    // },
    // {
    //   "_id": "message_4",
    //   "conversationId": "12345", // ID của cuộc hội thoại
    //   "senderId": "user2_id", // ID của người gửi
    //   "receiverId": "user1_id", // ID của người nhận
    //   "messageText": "Just work mostly. How about you?", // Nội dung tin nhắn
    //   "timestamp": "2024-09-05T10:03:00Z", // Thời gian tin nhắn được gửi
    //   "isRead": false // Tin nhắn chưa đọc
    // },
    // {
    //   "_id": "message_1",
    //   "conversationId": "12345", // ID của cuộc hội thoại
    //   "senderId": "user1_id", // ID của người gửi
    //   "receiverId": "user2_id", // ID của người nhận
    //   "messageText": "Hello, how are you?", // Nội dung tin nhắn
    //   "timestamp": "2024-09-05T10:00:00Z", // Thời gian tin nhắn được gửi
    //   "isRead": false // Tin nhắn chưa đọc
    // },
    // {
    //   "_id": "message_3",
    //   "conversationId": "12345", // ID của cuộc hội thoại
    //   "senderId": "user2_id", // ID của người gửi
    //   "receiverId": "user1_id", // ID của người nhận
    //   "messageText":
    //       "Oh, by the way, did you check the new update on the app?", // Nội dung tin nhắn tiếp theo
    //   "timestamp": "2024-09-05T10:02:00Z", // Thời gian tin nhắn được gửi
    //   "isRead": false // Tin nhắn chưa đọc
    // },
    // {
    //   "_id": "message_4",
    //   "conversationId": "12345", // ID của cuộc hội thoại
    //   "senderId": "user2_id", // ID của người gửi
    //   "receiverId": "user1_id", // ID của người nhận
    //   "messageText":
    //       "I think you’ll like the new features.", // Tin nhắn tiếp theo
    //   "timestamp":
    //       "2024-09-05T10:02:30Z", // Thời gian tin nhắn được gửi (gửi ngay sau tin nhắn trước đó)
    //   "isRead": false // Tin nhắn chưa đọc
    // },
    // {
    //   "_id": "message_5",
    //   "conversationId": "12345", // ID của cuộc hội thoại
    //   "senderId": "user1_id", // ID của người gửi
    //   "receiverId": "user2_id", // ID của người nhận
    //   "messageText":
    //       "Oh really? I haven’t checked it yet. Thanks for the heads-up!", // Tin nhắn phản hồi sau nhiều tin nhắn liên tiếp
    //   "timestamp": "2024-09-05T10:05:00Z", // Thời gian tin nhắn được gửi
    //   "isRead": false // Tin nhắn chưa đọc
    // },
    // //Tin nhắn hôm nay
    // {
    //   "_id": "message_2",
    //   "conversationId": "12345",
    //   "senderId": "user2_id",
    //   "receiverId": "user1_id",
    //   "messageText": "I'm good, thank you! How about you?",
    //   "timestamp": "2024-09-06T10:05:00Z",
    //   "isRead": true
    // },
    // {
    //   "_id": "message_3",
    //   "conversationId": "12345",
    //   "senderId": "user1_id",
    //   "receiverId": "user2_id",
    //   "messageText": "I'm doing well too! What are your plans for today?",
    //   "timestamp": "2024-09-06T10:07:00Z",
    //   "isRead": false
    // },
    // {
    //   "_id": "message_4",
    //   "conversationId": "12345",
    //   "senderId": "user2_id",
    //   "receiverId": "user1_id",
    //   "messageText":
    //       "I have a meeting this afternoon, but I'm free in the evening.",
    //   "timestamp": "2024-09-06T10:10:00Z",
    //   "isRead": false
    // },
    // {
    //   "_id": "message_5",
    //   "conversationId": "12345",
    //   "senderId": "user1_id",
    //   "receiverId": "user2_id",
    //   "messageText": "That sounds great! Let's catch up later then.",
    //   "timestamp": "2024-09-06T10:15:00Z",
    //   "isRead": false
    // }
  ];

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      double currentScrollPosiion = _scrollController.offset;
      if (currentScrollPosiion <= maxScrollExtent - 0.7 * maxScrollExtent) {
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
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceSize = MediaQuery.of(context).size;
    Utils.logMessage(
        'build my chat screen: ${GoRouterState.of(context).matchedLocation}');
    return Scaffold(
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
            backgroundImage: NetworkImage(
                'https://pics.craiyon.com/2023-11-20/Ud5thxsrQ16T6n0TDZ6BsA.webp'),
          ),
          title: Text(
            'Gojo Satoru',
            style: textTheme.bodyLarge!.copyWith(
              color: theme.indicatorColor,
            ),
          ),
          subtitle: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.circle,
                    color: Colors.green,
                    size: 10,
                  ),
                ),
                WidgetSpan(
                  child: const SizedBox(
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
                  messages.length,
                  (index) {
                    final message = messages[index];
                    final messageDate =
                        DateTime.parse(message['timestamp'] as String);
                    final previousMessageDate = index > 0
                        ? DateTime.parse(
                            messages[index - 1]['timestamp'] as String)
                        : null;
                    final showDateLabel = previousMessageDate == null ||
                        messageDate.day != previousMessageDate.day;
                    final isLastInSequence = index == messages.length - 1 ||
                        message['senderId'] != messages[index + 1]['senderId'];
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
                return SizedBox.shrink();
              }
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: IconButton(
                    alignment: Alignment.bottomCenter,
                    onPressed: _scrollToBottom,
                    icon: SizedBox(
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
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _searchController,
              focusNode: _focusNode,
              onTap: () {},
              decoration: InputDecoration(
                constraints: BoxConstraints.tightFor(height: 60),
                hintText: 'Tin nhắn',
                prefixIcon: const Icon(Icons.message),
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
          IconButton(onPressed: _sendMessage, icon: Icon(Icons.send))
        ],
      ),
    );
  }

  // Hàm xây dựng widget tin nhắn
  Widget _buildMessageWidget(
      Map<String, dynamic> message, int index, bool isEmployer) {
    // Kiểm tra xem tin nhắn có phải của người dùng hiện tại không
    final isMyMessage = (isEmployer && message['senderId'] == 'user2_id') ||
        (!isEmployer && message['senderId'] == 'user1_id');
    // Kiểm tra xem tin nhắn có liền mạch với tin nhắn trước đó không
    final isSeamlessMessages =
        index > 0 && message['senderId'] == messages[index - 1]['senderId'];
    // Kiểm tra xem tin nhắn có phải là tin nhắn cuối cùng trong chuỗi không
    final isLastInSequence = index == messages.length - 1 ||
        message['senderId'] != messages[index + 1]['senderId'];
    // Đường dẫn avatar của người gửi tin nhắn
    final avatarLink = isEmployer
        ? 'https://preview.redd.it/%E5%8E%9F%E7%A5%9E%E6%96%B0%E6%98%A5%E5%A4%B4%E5%83%8F-genshin-impact-spring-festival-avatar-part-1-v0-pt5hoxg8xqda1.jpg?width=640&crop=smart&auto=webp&s=6977e93f2120a402da408d1f6c872c2b8516dd24'
        : 'https://pics.craiyon.com/2023-11-20/Ud5thxsrQ16T6n0TDZ6BsA.webp';

    // Nếu là tin nhắn của người dùng hiện tại
    if (isMyMessage) {
      return MyMessages(
        message: message['messageText'] as String, // Nội dung tin nhắn
        timestamp: message['timestamp'] as String, // Thời gian gửi tin nhắn
        isLastInSequence: isLastInSequence, // Tin nhắn cuối cùng trong chuỗi
      );
    } else {
      // Nếu là tin nhắn của đối phương
      return OpponentMessages(
        message: message['messageText'] as String, // Nội dung tin nhắn
        timestamp: message['timestamp'] as String, // Thời gian gửi tin nhắn
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
  final String timestamp;
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
                      DateFormat('HH:mm').format(DateTime.parse(timestamp)),
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
  final String timestamp;
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
                      DateFormat('HH:mm').format(DateTime.parse(timestamp)),
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
