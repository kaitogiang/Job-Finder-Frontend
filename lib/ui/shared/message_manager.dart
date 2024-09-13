import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/conversation.dart';
import 'package:job_finder_app/models/message.dart';
import 'package:job_finder_app/models/user.dart';
import 'package:job_finder_app/services/conversation.service.dart';
import 'package:job_finder_app/services/socket_service.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

class MessageManager extends ChangeNotifier {
  SocketService? _socketService;
  AuthToken? _authToken;
  final ConversationService _conversationService;
  List<Conversation> _conversations = [];

  int _unseenJobseekerMessages = 0;
  int _unseenEmployerMessages = 0;

  //Hàm này sai nghiêm trọng tại vì ban đầu khởi tao MessageManager ở ProxyProvider thì
  //Token không được truyền vào hàm xây dựng mà truyền vào setter của authToken
  //Nên khi này khởi tạo thì nó sẽ tạo một Socket service mới chứa không còn là tham chiếu
  //mà trong khi đó tại AuthManager đã khởi tạo SocketService rồi nên có nghĩa là socket được
  //tạo ra tới hai lần dến server, một cái thì token không null, còn socket còn lại ở trong
  //Hàm xây dựng này là null, vì null nên khi gửi lên server thì nó sẽ bị chặn lại ở socket middleware.
  //Chính vì vậy mà nó bị reconnect liên tục.
  // MessageManager([AuthToken? authToken])
  //     : _socketService = SocketService(authToken),
  //       _conversationService = ConversationService(authToken),
  //       _authToken = authToken;

  MessageManager([AuthToken? authToken])
      : _conversationService = ConversationService(authToken),
        _authToken = authToken;

  //Định nghĩa các hàm setter

  set socketService(SocketService? socketService) {
    _socketService = socketService;
    notifyListeners();
  }

  set authToken(AuthToken? authToken) {
    _conversationService.authToken = authToken;
    _authToken = authToken;
    notifyListeners();
  }

  set unseenJobseekerMessages(int unseenJobseekerMessages) {
    _unseenJobseekerMessages = unseenJobseekerMessages;
    notifyListeners();
  }

  set unseenEmployerMessages(int unseenEmployerMessages) {
    _unseenEmployerMessages = unseenEmployerMessages;
    notifyListeners();
  }

  //Định nghĩa các hàm getter

  List<Conversation> get conversations => _conversations;

  int get unseenJobseekerMessages => _unseenJobseekerMessages;

  int get unseenEmployerMessages => _unseenEmployerMessages;

  Conversation getConversation(String conversationId) => _conversations
      .where((conversation) => conversation.id == conversationId)
      .first;

  //Định nghĩa các hàm xử lý tin nhắn
  //Nạp tất cả các cuộc trò chuyện của jobseeker với các nhà tuyển dụng khác
  Future<void> getAllConversation() async {
    try {
      if (_authToken!.isEmployer) {
        final conversations =
            await _conversationService.getAllEmployerConversation();
        _conversations = conversations;
        _unseenEmployerMessages = _conversations.fold(0,
            (sum, conversation) => sum + conversation.unseenEmployerMessages);
      } else {
        final conversations =
            await _conversationService.getAllJobseekerConversation();
        _conversations = conversations;
        _unseenJobseekerMessages = _conversations.fold(0,
            (sum, conversation) => sum + conversation.unseenJobseekerMessages);
      }

      notifyListeners();
    } catch (error) {
      Utils.logMessage(
          'Error in getAllJobseekerConversation method of MessageManager: $error');
    }
  }

  //Hàm gửi tin nhắn mới
  void sendMessage(
      String conversationId, String messageText, bool senderIsJobseeker) {
    final conversation = getConversation(conversationId);
    conversation.messages.add(Message(
      id: '${conversation.messages.length + 1}',
      conversationId: conversationId,
      senderId: 'user1_id',
      receiverId: 'user2_id',
      senderIsJobseeker: senderIsJobseeker,
      messageText: messageText,
      timestamp: DateTime.now(),
      isRead: false,
    ));
    notifyListeners();
  }
}
