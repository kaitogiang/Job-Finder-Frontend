import 'dart:convert';
import 'dart:ffi';

import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/conversation.dart';
import 'package:job_finder_app/services/node_service.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

class ConversationService extends NodeService {
  ConversationService([AuthToken? authToken]) : super(authToken);

  final headers = {'Content-Type': 'application/json; charset=UTF-8'};

  //Hàm tạo mới một conversation
  Future<bool> createConversation(String jobseekerId, String companyId) async {
    try {
      await httpFetch('$databaseUrl/api/conversation',
          headers: headers,
          method: HttpMethod.post,
          body: jsonEncode({
            'jobseekerId': jobseekerId,
            'companyId': companyId,
          }));
      return true;
    } catch (error) {
      Utils.logMessage(
          'Error in createConversation method of ConversationService: $error');
      return false;
    }
  }

  //Kiểm tra cuộc trò chuyện giữa nhà tuyển dụng dựa vào jobseekerId và companyId
  //Khi gửi companyId vào thì server tự động truy xuất employerId dựa vào companyId
  //Sau đó dựa vào cặp jobseekerId và employerId để truy xuất conversationId
  //Nếu tồn tại conversation thì trả về conversationId, ngược lại trả về null
  Future<String?> isExistingConversation(
      String jobseekerId, String companyId) async {
    try {
      final response = await httpFetch(
          '$databaseUrl/api/conversation/participants?jobseekerId=$jobseekerId&companyId=$companyId',
          headers: headers,
          method: HttpMethod.get) as Map<String, dynamic>?;
      if (response == null) {
        return null;
      }
      return response['_id'] as String;
    } catch (error) {
      Utils.logMessage(
          'Error in getConversationByParticipantId method of ConversationService: $error');
      return null;
    }
  }

  //Hàm nạp tất cả các conversation của một jobseeker
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

  //Hàm nạp tất cả các conversation của một employer
  Future<List<Conversation>> getAllEmployerConversation() async {
    try {
      final response = await httpFetch(
          '$databaseUrl/api/conversation/employer/$userId',
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
}
