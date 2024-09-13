import 'package:job_finder_app/ui/shared/utils.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final bool senderIsJobseeker;
  final String messageText;
  final DateTime timestamp;
  final bool
      isRead; //thuộc tính này là trạng thái đã đọc của tin nhắn người khác
  //nếu senderIsJobseeker là true thì isRead là trạng thái đã đọc của employer, ngược lại isRead là trạng thái đã đọc của jobseeker

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.senderIsJobseeker,
    required this.messageText,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      senderIsJobseeker: json['senderIsJobseeker'],
      messageText: json['messageText'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderIsJobseeker': senderIsJobseeker,
      'messageText': messageText,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
