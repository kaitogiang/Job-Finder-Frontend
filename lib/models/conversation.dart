import 'package:job_finder_app/models/message.dart';
import 'package:job_finder_app/models/user.dart';

class Conversation {
  final String id;
  final User opponent;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unseenMessages;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.opponent,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unseenMessages,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      opponent: json['opponent'],
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      unseenMessages: json['unseenMessages'],
      messages:
          json['messages'].map((message) => Message.fromJson(message)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opponent': opponent,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unseenMessages': unseenMessages,
      'messages': messages,
    };
  }
}
