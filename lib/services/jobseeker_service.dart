import 'dart:convert';
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

  //TODO: Hàm thêm các kỹ năng mới vào cơ sở dữ liệu
  Future<List<String>?> appendSkills(List<String> skills) async {
    try {
      final responese = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/skills',
        method: HttpMethod.post,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({"skills": skills}),
      ) as Map<String, dynamic>;
      List<dynamic> originalList = responese['updatedSkills'] as List<dynamic>;
      List<String> result = originalList.map((e) => e.toString()).toList();

      log('jobservice: asdfasdf');
      return result;
    } catch (error) {
      log('job service: ${error}');
      return null;
    }
  }
}
