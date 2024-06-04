import 'dart:developer';
import 'dart:io';

import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/node_service.dart';

import '../models/jobseeker.dart';

class JobseekerService extends NodeService {
  JobseekerService([AuthToken? authToken]) : super(authToken);

  Future<Map<String, dynamic>?> updateProfile(
      Map<String, String> updatedUser, File? file) async {
    try {
      final updateProfile = await httpUpload(
          '$databaseUrl/api/jobseeker/$userId',
          file: file,
          fields: updatedUser) as Map<String, dynamic>?;

      if (updateProfile != null) {
        log('job service Đã cập nhật người dùng');
        return updateProfile;
      } else {
        return null;
      }
    } catch (error) {
      log('job service: ${error}');
      return null;
    }
  }
}
