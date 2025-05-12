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

  MessageManager([AuthToken? authToken])
      : _conversationService = ConversationService(authToken),
        _authToken = authToken;

  // Getters and setters
  List<Conversation> get conversations => _conversations;
  int get unseenJobseekerMessages => _unseenJobseekerMessages;
  int get unseenEmployerMessages => _unseenEmployerMessages;

  Conversation getConversation(String conversationId) {
    return _conversations.firstWhere((c) => c.id == conversationId);
  }

  set socketService(SocketService? socketService) {
    _socketService = socketService;
    notifyListeners();
  }

  set authToken(AuthToken? authToken) {
    _conversationService.authToken = authToken;
    _authToken = authToken;
    notifyListeners();
  }

  set unseenJobseekerMessages(int value) {
    _unseenJobseekerMessages = value;
    notifyListeners();
  }

  set unseenEmployerMessages(int value) {
    _unseenEmployerMessages = value;
    notifyListeners();
  }

  // Increase unread messages for employer or jobseeker
  // If receiverIsEmployer is true, increase employer unread messages
  // Otherwise increase jobseeker unread messages
  void _increaseUnseenMessages(bool isRead, bool receiverIsEmployer, Conversation conversation) {
    if (isRead) return;

    if (receiverIsEmployer) {
      conversation.unseenEmployerMessages++;
      _unseenEmployerMessages++;
    } else {
      conversation.unseenJobseekerMessages++;
      _unseenJobseekerMessages++;
    }
  }

  // Reset unread message count to 0 for specific user
  void _resetUnseenMessages(Conversation conversation, bool userIsEmployer) {
    if (userIsEmployer) {
      conversation.unseenEmployerMessages = 0;
      _unseenEmployerMessages = 0;
    } else {
      conversation.unseenJobseekerMessages = 0;
      _unseenJobseekerMessages = 0;
    }
  }

  // Create a new conversation
  Future<String?> createConversation(String companyId, [String? jobseekerId]) async {
    try {
      final conversation = await _conversationService.createConversation(companyId, jobseekerId);
      if (conversation != null) {
        conversations.add(conversation);
        // Emit create conversation event to notify employer about new conversation
        _socketService?.createConversation(conversation);
        notifyListeners();
        return conversation.id;
      }
      Utils.logMessage('Error: Could not add conversation to list');
      return null;
    } catch (error) {
      Utils.logMessage('Error creating conversation: $error');
      return null;
    }
  }

  // Listen for new conversations created by jobseekers
  void listenForNewConversation() {
    if (_socketService?.conversationController.hasListener ?? true) return;

    _socketService?.conversationStream.listen((newConversation) {
      Utils.logMessage('Received new conversation from jobseeker');
      conversations.add(newConversation);
      notifyListeners();
    });
  }

  // Load all conversations for either jobseeker or employer
  Future<void> getAllConversation() async {
    try {
      if (_authToken!.isEmployer) {
        _conversations = await _conversationService.getAllEmployerConversation();
        _unseenEmployerMessages = _conversations.fold(
          0,
          (sum, conv) => sum + conv.unseenEmployerMessages
        );
      } else {
        _conversations = await _conversationService.getAllJobseekerConversation();
        _unseenJobseekerMessages = _conversations.fold(
          0,
          (sum, conv) => sum + conv.unseenJobseekerMessages
        );
      }
      notifyListeners();
    } catch (error) {
      Utils.logMessage('Error getting conversations: $error');
    }
  }

  // Send a new message
  Future<void> sendMessage(String conversationId, String messageText, bool senderIsJobseeker) async {
    final conversation = getConversation(conversationId);
    final isEmployer = _authToken?.isEmployer ?? false;
    final senderId = _authToken?.userId;
    final receiverId = isEmployer ? conversation.jobseeker.id : conversation.employer.id;

    final newMessage = Message(
      id: '',
      conversationId: conversationId,
      senderId: senderId!,
      receiverId: receiverId,
      senderIsJobseeker: senderIsJobseeker,
      messageText: messageText,
      timestamp: DateTime.now(),
      isRead: false
    );

    try {
      final fullMessage = await _conversationService.sendMessage(newMessage);
      if (fullMessage != null) {
        conversation.messages.add(fullMessage);
        _socketService?.sendMessage(conversationId, receiverId, fullMessage);
        conversation.lastMessage = fullMessage.messageText;
        conversation.lastMessageTime = fullMessage.timestamp;
      } else {
        Utils.logMessage('Failed to send message - null response');
      }
    } catch (error) {
      Utils.logMessage('Error sending message: $error');
    }
    notifyListeners();
  }

  // Join a conversation room
  void joinConversation(String conversationId) {
    _socketService?.joinRoom(conversationId);
  }

  // Leave a conversation room
  void leaveConversation(String conversationId) {
    _socketService?.leaveRoom(conversationId);
  }

  // Listen for incoming real-time messages and add them to message list
  void listenToIncomingMessages() {
    if (_socketService?.messageController.hasListener ?? true) return;

    _socketService?.messageStream.listen((message) {
      final currentConversation = getConversation(message.conversationId);
      
      currentConversation.messages.add(message);
      currentConversation.lastMessage = message.messageText;
      currentConversation.lastMessageTime = message.timestamp;

      final receiverIsEmployer = message.senderIsJobseeker;
      _increaseUnseenMessages(message.isRead, receiverIsEmployer, currentConversation);
      
      notifyListeners();
    });
  }

  // Check if conversation between jobseeker and company exists
  // Returns conversation ID if exists
  Future<String?> verifyExistingConversation(String companyId, [String? jobseekerId]) async {
    try {
      return await _conversationService.isExistingConversation(companyId, jobseekerId);
    } catch (error) {
      Utils.logMessage('Error verifying conversation: $error');
      return null;
    }
  }

  // Update read status for user messages
  void _setReadStatusForUserMessages(String conversationId, String userId, bool userIsEmployer) {
    final conversation = getConversation(conversationId);
    
    for (var message in conversation.messages) {
      if (message.receiverId == userId && !message.isRead) {
        message.isRead = true;
      }
    }
    
    _resetUnseenMessages(conversation, userIsEmployer);
  }

  // Mark messages as read
  Future<void> readMessages(String conversationId, String userId, bool userIsEmployer) async {
    try {
      final success = await _conversationService.markMessageAsRead(
        conversationId, 
        userId,
        userIsEmployer
      );

      if (success) {
        _setReadStatusForUserMessages(conversationId, userId, userIsEmployer);
        notifyListeners();
      } else {
        Utils.logMessage('Failed to mark messages as read');
      }
    } catch (error) {
      Utils.logMessage('Error marking messages as read: $error');
    }
  }
}
