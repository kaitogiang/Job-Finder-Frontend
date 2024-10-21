import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/conversation.dart';
import 'package:job_finder_app/models/message.dart';
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

  //Tăng tin nhắn chưa đọc cho nhà tuyển dụng hoặc người tìm việc
  //Nếu receiverIsEmployer có nghĩa là người nhận là Employer => tăng tin nhắn chưa đọc
  //Ngược là thì tăng tin nhắn chưa đọc cho Jobseeker
  void _increaseUnseenMessages(
      bool isRead, bool receiverIsEmployer, Conversation conversation) {
    //Nếu tin nhắn đã được đọc thì không cần tăng thêm số lượng tin nhắn
    if (isRead) return;
    //Tăng tin nhắn chưa đọc cho Employer
    if (receiverIsEmployer) {
      conversation.unseenEmployerMessages++;
      _unseenEmployerMessages++;
      // notifyListeners();
    } else {
      //Tăng tin nhắn chưa đọc cho Jobseeker
      conversation.unseenJobseekerMessages++;
      _unseenJobseekerMessages++;
      // notifyListeners();
    }
  }

  //Reset lại số lượng tin nhắn chưa đọc về 0 của từng người dùng cụ thể
  void _resetUnseenMessages(Conversation conversation, bool userIsEmployer) {
    //Nếu là employer thì reset biến unseenEmployerMessages và ngược lại
    if (userIsEmployer) {
      //Reset thuộc tính của conversation
      conversation.unseenEmployerMessages = 0;
      //Reset lại biến quan sát giá trị unseenMessages
      _unseenEmployerMessages = 0;
    } else {
      //Reset thuộc tính của conversation dành cho jobseeker
      conversation.unseenJobseekerMessages = 0;
      _unseenJobseekerMessages = 0;
    }
  }

  //Hàm tạo conversation
  Future<String?> createConversation(String companyId) async {
    try {
      final conversation =
          await _conversationService.createConversation(companyId);
      if (conversation != null) {
        conversations.add(conversation);
        //Gọi sự kiện tạo conversation để báo hiệu cho Employer biết có conversation mới
        _socketService?.createConversation(conversation);
        notifyListeners();
        return conversation.id;
      } else {
        Utils.logMessage(
            'Error in createConversation of MessageManager, cannot add to conversations list');
        return null;
      }
    } catch (error) {
      Utils.logMessage('Error in createConversation of MessageManager: $error');
      return null;
    }
  }

  void listenForNewConversation() {
    if (_socketService?.conversationController.hasListener ?? true) return;
    //Lắng nghe sự kiện tạo conversation mới của jobseeker
    _socketService?.conversationStream.listen((newConversation) {
      Utils.logMessage('Nhan duoc conversation moi tu Jobseeker!!!');
      conversations.add(newConversation);
      notifyListeners();
    });
  }

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
  Future<void> sendMessage(
      String conversationId, String messageText, bool senderIsJobseeker) async {
    //Lấy thông tin về conversation, vài trò người nhắn và id của họ
    final conversation = getConversation(conversationId);
    bool isEmployer = _authToken?.isEmployer ?? false;
    final senderId = _authToken?.userId;

    //Quyết định id của người nhận tùy thuộc vào giá trị isEmployer
    //Nếu là jobseeker thì người nhận là employer và ngược lại
    final receiverId =
        isEmployer ? conversation.jobseeker.id : conversation.employer.id;

    Message newMessage = Message(
        id: '',
        conversationId: conversationId,
        senderId: senderId!,
        receiverId: receiverId,
        senderIsJobseeker: senderIsJobseeker,
        messageText: messageText,
        timestamp: DateTime.now(),
        isRead: false);
    try {
      Message? fullMessage = await _conversationService.sendMessage(newMessage);
      if (fullMessage != null) {
        Utils.logMessage('Gửi message thành công');
        conversation.messages.add(fullMessage);
        _socketService?.sendMessage(conversationId, receiverId, fullMessage);
        conversation.lastMessage = fullMessage.messageText;
        conversation.lastMessageTime = fullMessage.timestamp;
      } else {
        Utils.logMessage('Message bị null, gửi thất bại');
      }
    } catch (error) {
      Utils.logMessage('Error in sendMessage method of MessageManager: $error');
    }
    // _socketService?.sendMessage();
    notifyListeners();
  }

  // void _addMessageToConversation(Message newMessage) {
  //   Conversation currentConversation =
  //       getConversation(newMessage.conversationId);
  //   currentConversation.messages.add(newMessage);
  // }

  //Hàm tham gia vào một cuộc trò chuyện
  void joinConversation(String conversationId) {
    _socketService?.joinRoom(conversationId);
  }

  void leaveConversation(String conversationId) {
    _socketService?.leaveRoom(conversationId);
  }

  //Hàm nhận tin nhắn real time và thêm vào trong danh sách tin nhắn
  void listenToIncomingMessages() {
    if (_socketService?.messageController.hasListener ?? true) return;
    _socketService?.messageStream.listen((message) {
      //Hiển thị tin nhắn ra
      Utils.logMessage('Tin nhắn mới: ${message.messageText}');
      // _addMessageToConversation(message);
      Conversation currentConversation =
          getConversation(message.conversationId);
      currentConversation.messages.add(message);
      currentConversation.lastMessage = message.messageText;
      currentConversation.lastMessageTime = message.timestamp;

      Utils.logMessage(
          'unseenEmployerMessage before ----: ${currentConversation.unseenEmployerMessages}');
      Utils.logMessage(
          'unseenJobseekerMessage before----: ${currentConversation.unseenJobseekerMessages}');

      //Tăng số lượng tin nhắn chưa đọc nếu nhận tin nhắn mà không có trong converation
      bool senderIsJobseeker = message.senderIsJobseeker;
      bool receiverIsEmployer = senderIsJobseeker ? true : false;
      //Gọi hàm cập nhật số lượng tin nhắn chưa đọc
      _increaseUnseenMessages(
          message.isRead, receiverIsEmployer, currentConversation);
      Utils.logMessage(
          'unseenEmployerMessage: ${currentConversation.unseenEmployerMessages}');
      Utils.logMessage(
          'unseenJobseekerMessage: ${currentConversation.unseenJobseekerMessages}');
      notifyListeners();
    });
  }

  //Hàm kiểm tra cuộc trò chuyện giữa jobseeker và company đã có chưa, nó có tồn tại thì trả về id của conversation
  Future<String?> verifyExistingConversation(String companyId) async {
    try {
      final conversationId =
          await _conversationService.isExistingConversation(companyId);
      return conversationId;
    } catch (error) {
      Utils.logMessage('Exception occur in verifyExistingConversation: $error');
      return null;
    }
  }

  void _setReadStatusForUserMessages(
      String conversationId, String userId, bool userIsEmployer) {
    //Truy xuất conversation cụ thể và danh sách tin nhắn cụ thể
    Conversation conversation = getConversation(conversationId);
    List<Message> messages = conversation.messages;
    //Cập nhật trạng thái đã đọc của những tin nhắn được gửi tới mình
    for (var message in messages) {
      if (message.receiverId == userId && !message.isRead) {
        message.isRead = true;
      }
    }
    //Cập nhật lại số lượng trong conversation và biến quan sát số lượng tin nhắn chưa đọc
    _resetUnseenMessages(conversation, userIsEmployer);
  }

  //Hàm đánh dấu tin nhắn đã đọc
  Future<void> readMessages(
      String conversationId, String userId, bool userIsEmployer) async {
    try {
      final result = await _conversationService.markMessageAsRead(
          conversationId, userId, userIsEmployer);
      if (result) {
        Utils.logMessage('Read messages sucessfully');
        //Gọi hàm cập nhật trạng thái đã đọc
        _setReadStatusForUserMessages(conversationId, userId, userIsEmployer);
        //báo cho UI để cập nhật lại giao diện
        notifyListeners();
      } else {
        Utils.logMessage('Cannot read messages');
      }
    } catch (error) {
      Utils.logMessage('Error in readMessage of MessageManager: $error');
    }
  }
}
