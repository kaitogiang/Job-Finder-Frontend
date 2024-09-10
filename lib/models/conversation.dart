import 'package:job_finder_app/models/message.dart';
import 'package:job_finder_app/models/user.dart';

class Conversation {
  final String id;
  final User jobseeker;
  final User employer;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unseenMessages;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.jobseeker,
    required this.employer,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unseenMessages,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      jobseeker: json['jobseeker'],
      employer: json['employer'],
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
      'jobseeker': jobseeker,
      'employer': employer,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unseenMessages': unseenMessages,
      'messages': messages,
    };
  }
}
