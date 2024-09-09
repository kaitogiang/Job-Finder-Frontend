class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String messageText;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
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
      'messageText': messageText,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
