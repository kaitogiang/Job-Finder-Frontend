import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/models/resume.dart';
import 'package:job_finder_app/services/node_service.dart';

import '../models/jobseeker.dart';

class JobseekerService extends NodeService {
  JobseekerService([AuthToken? authToken]) : super(authToken);

  Future<Jobseeker?> fetchJobseekerInfo() async {
    try {
      final response = await httpFetch('$databaseUrl/api/jobseeker/$userId',
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          method: HttpMethod.get) as Map<String, dynamic>;
      final jobseeker = Jobseeker.fromJson(response);

      return jobseeker;
    } catch (error) {
      log('job service: ${error}');
      return null;
    }
  }

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

  Future<bool> removeSkill(String skill) async {
    try {
      final result = await httpFetch(
          '$databaseUrl/api/jobseeker/$userId/skills/$skill',
          method: HttpMethod.delete) as Map<String, dynamic>;
      if (result['updatedUser'] != null) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      log('job service: ${error}');
      return false;
    }
  }

  Future<Resume?> uploadResume(String filename, File file) async {
    try {
      final result = await httpUpload(
          '$databaseUrl/api/jobseeker/$userId/resume',
          file: file,
          fields: {'filename': filename},
          fileFieldName: 'resume') as Map<String, dynamic>;
      Map<String, dynamic> pdfValue = result['pdf'][0];
      Resume resume = Resume.fromJson(pdfValue);

      return resume;
    } catch (error) {
      log('job service: ${error}');
      return null;
    }
  }

  //Todo service để xóa file cv
  Future<bool> deleteResume() async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/resume',
        method: HttpMethod.delete,
      );
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      log('job service: ${error}');
      return false;
    }
  }

  //TODO Hàm dùng để thêm kinh nghiệm mới
  Future<List<Experience>?> appendExperience(
      Map<String, String> expValue) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/experience',
        method: HttpMethod.post,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(expValue),
      ) as Map<String, dynamic>;
      List<dynamic> newList = result['experience'] as List<dynamic>;
      //Todo Ép kiểu từng phần tử trong List<dynamic>
      List<Experience> exp =
          newList.map((e) => Experience.fromJson(e)).toList();
      return exp;
    } catch (error) {
      log('job service: ${error}');
      return null;
    }
  }

  Future<bool> removeExperience(int index) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/experience/$index',
        method: HttpMethod.delete,
      );
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      log('job service: ${error}');
      return false;
    }
  }

  Future<List<Education>?> addEducation(Education edu) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/education',
        method: HttpMethod.post,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(edu.toJson()),
      );
      List<dynamic> education = result['education'] as List<dynamic>;
      //todo chuyển từng phần tử trong education thành đối tượng Education
      List<Education> eduList =
          education.map((e) => Education.fromJson(e)).toList();
      return eduList;
    } catch (error) {
      log('job service: ${error}');
      return null;
    }
  }

  Future<bool> removeEducation(int index) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/education/$index',
        method: HttpMethod.delete,
      );
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      log('job service: ${error}');
      return false;
    }
  }

  Future<Education?> updateEducation(int index, Education edu) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/education/$index',
        method: HttpMethod.patch,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(edu.toJson()),
      );
      List<dynamic> originalList = result['education'] as List<dynamic>;
      List<Education> eduList =
          originalList.map((e) => Education.fromJson(e)).toList();
      return eduList[0];
    } catch (error) {
      log('job service: ${error}');
      return null;
    }
  }

  Future<Experience?> updateExperience(
      int index, Map<String, String> data) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/experience/$index',
        method: HttpMethod.patch,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(data),
      );
      List<dynamic> originalList = result['experience'] as List<dynamic>;
      List<Experience> expList =
          originalList.map((e) => Experience.fromJson(e)).toList();
      return expList[0];
    } catch (error) {
      log('job service: ${error}');
      return null;
    }
  }

  Future<String?> changeEmail(String password, String email) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/change-email',
        method: HttpMethod.patch,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({"password": password, "email": email}),
      ) as Map<String, dynamic>;

      if (result['newEmail'] != null) {
        return result['newEmail'] as String;
      }
    } catch (error) {
      log('Lỗi trong job service: ${error}');
      return null;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/change-password',
        method: HttpMethod.patch,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(
            {"oldPassword": oldPassword, "newPassword": newPassword}),
      ) as Map<String, dynamic>;
      final isChanged = result['isChanged'] as bool;
      return isChanged;
    } catch (error) {
      log('Lỗi trong job service ${error}');
      return false;
    }
  }
}
