import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:job_finder_app/models/employer.dart';

import 'node_service.dart';

class EmployerService extends NodeService {
  EmployerService([super.authToken]);

  final headers = {'Content-Type': 'application/json; charset=UTF-8'};

  Future<Employer?> fetchEmployerInfo() async {
    try {
      final response = await httpFetch('$databaseUrl/api/employer/$userId',
          headers: headers, method: HttpMethod.get) as Map<String, dynamic>;
      final employer = Employer.fromJson(response);

      return employer;
    } catch (error) {
      log('Error in fetchEmployerInfo method of Employer: $error');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProfile(
      Map<String, String> updatedUser, File? file) async {
    try {
      final updateProfile = await httpUpload(
          '$databaseUrl/api/employer/$userId',
          file: file,
          fields: updatedUser) as Map<String, dynamic>;

      return updateProfile;
    } catch (error) {
      log('Error in updateProfile method of Employer: $error');
      return null;
    }
  }

  Future<String?> changeEmail(String password, String email) async {
    try {
      final result = await httpFetch(
              '$databaseUrl/api/employer/$userId/change-email',
              method: HttpMethod.patch,
              headers: headers,
              body: jsonEncode({"password": password, "email": email}))
          as Map<String, dynamic>;

      if (result['newEmail'] != null) {
        return result['newEmail'] as String;
      }
    } catch (error) {
      log('Error in changeEmail method of Employer: $error');
      return null;
    }
    return null;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final result = await httpFetch(
              '$databaseUrl/api/employer/$userId/change-password',
              method: HttpMethod.patch,
              headers: headers,
              body: jsonEncode(
                  {"oldPassword": oldPassword, "newPassword": newPassword}))
          as Map<String, dynamic>;
      final isChanged = result['isChanged'] as bool;
      return isChanged;
    } catch (error) {
      log('Error in changePassword method of Employer: $error');
      return false;
    }
  }
}
