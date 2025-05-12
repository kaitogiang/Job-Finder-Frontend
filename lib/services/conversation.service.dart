import 'dart:convert';
import 'package:job_finder_app/models/conversation.dart';
import 'package:job_finder_app/models/message.dart';
import 'package:job_finder_app/services/node_service.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

class ConversationService extends NodeService {
  ConversationService(super.authToken);

  final headers = {'Content-Type': 'application/json; charset=UTF-8'};

  //Function to create a new conversation from the jobseeker side
  Future<Conversation?> createConversation(String companyId,
      [String? userId]) async {
    //Assign userId again if it is null
    userId = userId ?? super.userId;
    try {
      final response = await httpFetch('$databaseUrl/api/conversation',
          headers: headers,
          method: HttpMethod.post,
          body: jsonEncode({
            'jobseekerId': userId,
            'companyId': companyId,
          })) as Map<String, dynamic>?;
      if (response != null) {
        final conversationId = response['conversation'] as String;
        final conversationMap = await httpFetch(
          '$databaseUrl/api/conversation/$conversationId',
          headers: headers,
          method: HttpMethod.get,
        ) as Map<String, dynamic>?;
        if (conversationMap != null) {
          final conversation = Conversation.fromJson(conversationMap);
          return conversation;
        }
      }
      return null;
    } catch (error) {
      Utils.logMessage(
          'Error in createConversation method of ConversationService: $error');
      return null;
    }
  }

  //Check the conversation between the employer based on jobseekerId and companyId
  //When sending companyId, the server automatically retrieves employerId based on companyId
  //Then based on the pair of jobseekerId and employerId to retrieve conversationId
  //If the conversation exists, return conversationId, otherwise return null
  Future<String?> isExistingConversation(String companyId,
      [String? userId]) async {
    //Assign userId again if it is null
    userId = userId ?? super.userId;
    try {
      final response = await httpFetch(
          '$databaseUrl/api/conversation/participants?jobseekerId=$userId&companyId=$companyId',
          headers: headers,
          method: HttpMethod.get) as Map<String, dynamic>?;
      Utils.logMessage(response.toString());
      // if (response == null) {
      //   return null;
      // }
      return response?['_id'] as String?;
    } catch (error) {
      Utils.logMessage(
          'Error in getConversationByParticipantId method of ConversationService: $error');
      return null;
    }
  }

  //Function to load all conversations of a jobseeker
  Future<List<Conversation>> getAllJobseekerConversation() async {
    try {
      final response = await httpFetch(
          '$databaseUrl/api/conversation/jobseeker/$userId',
          headers: headers,
          method: HttpMethod.get) as List<dynamic>;
      List<Map<String, dynamic>> conversationsList =
          List<Map<String, dynamic>>.from(response);
      Utils.logMessage(conversationsList.toString());
      List<Conversation> conversations =
          conversationsList.map((e) => Conversation.fromJson(e)).toList();
      return conversations;
    } catch (error) {
      Utils.logMessage(
          'Error in getAllConversation method of ConversationService: $error');
      return [];
    }
  }

  //Function to load all conversations of an employer
  Future<List<Conversation>> getAllEmployerConversation() async {
    try {
      final response = await httpFetch(
          '$databaseUrl/api/conversation/employer/$userId',
          headers: headers,
          method: HttpMethod.get) as List<dynamic>;
      List<Map<String, dynamic>> conversationsList =
          List<Map<String, dynamic>>.from(response);
      // Utils.logMessage(conversationsList.toString());
      List<Conversation> conversations =
          conversationsList.map((e) => Conversation.fromJson(e)).toList();
      return conversations;
    } catch (error) {
      Utils.logMessage(
          'Error in getAllConversation method of ConversationService: $error');
      return [];
    }
  }

  //Function to send a message
  Future<Message?> sendMessage(Message newMessage) async {
    try {
      final response = await httpFetch('$databaseUrl/api/conversation/message/',
          headers: headers,
          method: HttpMethod.post,
          body: jsonEncode(newMessage.toJson())) as Map<String, dynamic>;
      Message decodedMessage = Message.fromJson(response);
      return decodedMessage;
    } catch (error) {
      Utils.logMessage('Error in sendMessage service, $error');
      return null;
    }
  }

  //Function to mark a message as read
  Future<bool> markMessageAsRead(
      String conversationId, String userId, bool userIsEmployer) async {
    //In Dart, when representing the Object type, it must have a full key and value, otherwise
    //It will be considered as a Set type
    Utils.logMessage('userIsEmployer: $userIsEmployer');
    try {
      final response =
          await httpFetch('$databaseUrl/api/conversation/mark-as-read',
              headers: headers,
              method: HttpMethod.patch,
              body: jsonEncode({
                'conversationId': conversationId,
                'userId': userId,
                'userIsEmployer': userIsEmployer
              })) as Map<String, dynamic>;
      if (response['messageMarkedAsRead'] == true) {
        return true;
      }
      return false;
    } catch (error) {
      Utils.logMessage(
          'Error in markMessageAsRead method of ConversationService: $error');
      return false;
    }
  }
}
