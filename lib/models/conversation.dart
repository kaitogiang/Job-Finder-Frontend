import 'package:job_finder_app/models/message.dart';
import 'package:job_finder_app/models/user.dart';

class Conversation {
  String id;
  User jobseeker;
  User employer;
  String lastMessage;
  DateTime lastMessageTime;
  int unseenJobseekerMessages;
  int unseenEmployerMessages;
  List<Message> messages;

  Conversation({
    required this.id,
    required this.jobseeker,
    required this.employer,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unseenJobseekerMessages,
    required this.unseenEmployerMessages,
    required this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // Utils.logMessage('${json['messages'].runtimeType}');
    // List<Map<String, dynamic>> messages =
    //     List<Map<String, dynamic>>.from(json['messages']);
    // List<Message> msgList = messages.map((e) => Message.fromJson(e)).toList();
    // Utils.logMessage('${msgList.runtimeType}');
    return Conversation(
      id: json['_id'],
      jobseeker: User.fromJson(json['jobseeker']),
      employer: User.fromJson(json['employer']),
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      unseenJobseekerMessages: json['unseenJobseekerMessages'],
      unseenEmployerMessages: json['unseenEmployerMessages'],
      messages: (json['messages'] as List<dynamic>)
          .map((message) => Message.fromJson(message))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'jobseeker': jobseeker.toJson(),
      'employer': employer.toJson(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unseenJobseekerMessages': unseenJobseekerMessages,
      'unseenEmployerMessages': unseenEmployerMessages,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}
