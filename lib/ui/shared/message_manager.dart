import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/conversation.dart';
import 'package:job_finder_app/models/message.dart';
import 'package:job_finder_app/models/user.dart';
import 'package:job_finder_app/services/socket_service.dart';

class MessageManager extends ChangeNotifier {
  SocketService? _socketService;
  AuthToken? _authToken;

  final List<Conversation> _conversations = [
    Conversation(
      id: '1',
      jobseeker: User(
        id: 'user2_id',
        firstName: 'Devin',
        lastName: 'Glover',
        email: 'devin@example.com',
        phone: '1234567890',
        address: '1234 Main St, Anytown, USA',
        avatar:
            'https://www.dexerto.com/cdn-cgi/image/width=3840,quality=60,format=auto/https://editors.dexerto.com/wp-content/uploads/2022/08/25/nilou-eyes-closed-genshin-impact.jpg',
      ),
      employer: User(
        id: 'user1_id',
        firstName: 'Gojo',
        lastName: 'Satoru',
        email: 'devin@example.com',
        phone: '1234567890',
        address: '1234 Main St, Anytown, USA',
        avatar:
            'https://pics.craiyon.com/2023-11-20/Ud5thxsrQ16T6n0TDZ6BsA.webp',
      ),
      lastMessage: 'Hello, how are you?',
      lastMessageTime: DateTime.now(),
      unseenMessages: 0,
      messages: [
        Message(
          id: '1',
          conversationId: '1',
          senderId: 'user2_id',
          receiverId: 'user1_id',
          messageText: 'Hello, how are you?',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '2',
          conversationId: '1',
          senderId: 'user2_id',
          receiverId: 'user1_id',
          messageText: 'I am fine, thank you!',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '3',
          conversationId: '1',
          senderId: 'user1_id',
          receiverId: 'user2_id',
          messageText: 'What is your name?',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '4',
          conversationId: '1',
          senderId: 'user2_id',
          receiverId: 'user1_id',
          messageText: 'My name is Devin. What about you?',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '5',
          conversationId: '1',
          senderId: 'user1_id',
          receiverId: 'user2_id',
          messageText: 'I am Alex. Nice to meet you!',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '6',
          conversationId: '1',
          senderId: 'user2_id',
          receiverId: 'user1_id',
          messageText: 'Nice to meet you too, Alex! How are you doing today?',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '7',
          conversationId: '1',
          senderId: 'user1_id',
          receiverId: 'user2_id',
          messageText: 'I am doing well, thank you! How about you?',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '8',
          conversationId: '1',
          senderId: 'user2_id',
          receiverId: 'user1_id',
          messageText: 'I am great, thanks for asking!',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '9',
          conversationId: '1',
          senderId: 'user2_id',
          receiverId: 'user1_id',
          messageText: 'What are your plans for the weekend?',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '10',
          conversationId: '1',
          senderId: 'user2_id',
          receiverId: 'user1_id',
          messageText: 'I was thinking of going hiking. How about you?',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '11',
          conversationId: '1',
          senderId: 'user1_id',
          receiverId: 'user2_id',
          messageText: 'That sounds fun! I might join you if that’s okay.',
          timestamp: DateTime.now(),
          isRead: false,
        ),
      ],
    ),
    Conversation(
      id: '2',
      jobseeker: User(
        id: 'user2_id',
        firstName: 'Gojo',
        lastName: 'Satoru',
        email: 'devin@example.com',
        phone: '1234567890',
        address: '1234 Main St, Anytown, USA',
        avatar:
            'https://pics.craiyon.com/2023-11-20/Ud5thxsrQ16T6n0TDZ6BsA.webp',
      ),
      employer: User(
        id: 'user1_id',
        firstName: 'Devin',
        lastName: 'Glover',
        email: 'devin@example.com',
        phone: '1234567890',
        address: '1234 Main St, Anytown, USA',
        avatar:
            'https://www.dexerto.com/cdn-cgi/image/width=3840,quality=60,format=auto/https://editors.dexerto.com/wp-content/uploads/2022/08/25/nilou-eyes-closed-genshin-impact.jpg',
      ),
      lastMessage: 'I am fine, thank you!',
      lastMessageTime: DateTime.now(),
      unseenMessages: 1,
      messages: [
        Message(
          id: '4',
          conversationId: '2',
          senderId: 'user2_id',
          receiverId: 'user1_id',
          messageText: 'Do you play Genshin Impact!',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '5',
          conversationId: '2',
          senderId: 'user1_id',
          receiverId: 'user2_id',
          messageText: 'Yes, I do!',
          timestamp: DateTime.now(),
          isRead: false,
        ),
        Message(
          id: '6',
          conversationId: '2',
          senderId: 'user2_id',
          receiverId: 'user1_id',
          messageText: 'Do you want to play with me?',
          timestamp: DateTime.now(),
          isRead: false,
        ),
      ],
    ),
  ];

  List<Conversation> get conversations => _conversations;

  Conversation getConversation(String conversationId) => _conversations
      .where((conversation) => conversation.id == conversationId)
      .first;

  MessageManager([AuthToken? authToken])
      : _socketService = SocketService(authToken);

  set socketService(SocketService? socketService) {
    _socketService = socketService;
    notifyListeners();
  }

  set authToken(AuthToken? authToken) {
    _authToken = authToken;
    notifyListeners();
  }

  void sendMessage(String conversationId, String messageText) {
    final conversation = getConversation(conversationId);
    conversation.messages.add(Message(
      id: '${conversation.messages.length + 1}',
      conversationId: conversationId,
      senderId: 'user1_id',
      receiverId: 'user2_id',
      messageText: messageText,
      timestamp: DateTime.now(),
      isRead: false,
    ));
    notifyListeners();
  }
}
