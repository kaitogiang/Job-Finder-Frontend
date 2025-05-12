import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/models/locked_users.dart';
import 'package:job_finder_app/models/resume.dart';
import 'package:job_finder_app/services/node_service.dart';

import '../models/jobseeker.dart';
import '../ui/shared/utils.dart';

class JobseekerService extends NodeService {
  JobseekerService([super.authToken]);

  Future<Jobseeker?> fetchJobseekerInfo() async {
    try {
      final response = await httpFetch('$databaseUrl/api/jobseeker/$userId',
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          method: HttpMethod.get) as Map<String, dynamic>;
      final jobseeker = Jobseeker.fromJson(response);

      return jobseeker;
    } catch (error) {
      Utils.logMessage('job service: $error');
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
        Utils.logMessage('job service Đã cập nhật người dùng');
        return updateProfile;
      } else {
        return null;
      }
    } catch (error) {
      Utils.logMessage('job service: $error');
      return null;
    }
  }

  //Hàm thêm các kỹ năng mới vào cơ sở dữ liệu
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
      log('job service: $error');
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
      log('job service: $error');
      return false;
    }
  }
  Future<List<Resume>?> uploadResume(String filename, File file) async {
    try {
      final result = await httpUpload(
          '$databaseUrl/api/jobseeker/$userId/resume',
          file: file,
          fields: {'filename': filename},
          fileFieldName: 'resume') as Map<String, dynamic>;
      //Lấy danh sách các CV
      final List<dynamic> originalResumeList = result['pdf'] as List<dynamic>;
      //Chuyển mỗi phần tử bên trong mảng pdf thành kiểu Map
      final List<Map<String, dynamic>> resumeMapList =
          List<Map<String, dynamic>>.from(originalResumeList);
      //Chuyển các phần tử kiểu Map trong danh sách trên thành kiểu Resume
      final List<Resume> resumeList =
          resumeMapList.map((resume) => Resume.fromJson(resume)).toList();

      return resumeList;
    } catch (error) {
      log('job service: $error');
      return null;
    }
  }

  //Todo service để xóa file cv
  Future<bool> deleteResume(int index) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/jobseeker/$userId/resume/$index',
        method: HttpMethod.delete,
      );
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      log('job service: $error');
      return false;
    }
  }

  // Hàm dùng để thêm kinh nghiệm mới
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
      log('job service: $error');
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
      log('job service: $error');
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
      log('job service: $error');
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
      log('job service: $error');
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
      log('job service: $error');
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
      log('job service: $error');
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
      log('Lỗi trong job service: $error');
      return null;
    }
    return null;
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
      log('Lỗi trong job service $error');
      return false;
    }
  }

  // Future<bool> saveRegistrationToken() async {

  // }

  //-------PHẦN QUẢN LÝ DÀNH CHO ADMIN--------
  Future<List<Jobseeker>> getAllJobseekers() async {
    try {
      final result =
          await httpFetch('$databaseUrl/api/jobseeker') as List<dynamic>;
      List<Map<String, dynamic>> jobseekers =
          result.map((e) => e as Map<String, dynamic>).toList();
      List<Jobseeker> jobseekerList =
          jobseekers.map((e) => Jobseeker.fromJson(e)).toList();
      return jobseekerList;
    } catch (error) {
      Utils.logMessage('job service in getAllJobseekers: $error');
      return [];
    }
  }

  Future<List<Jobseeker>> getAllRecentJobseekers() async {
    try {
      final result =
          await httpFetch('$databaseUrl/api/jobseeker/recent') as List<dynamic>;
      List<Map<String, dynamic>> jobseekers =
          result.map((e) => e as Map<String, dynamic>).toList();
      List<Jobseeker> jobseekerList =
          jobseekers.map((e) => Jobseeker.fromJson(e)).toList();
      return jobseekerList;
    } catch (error) {
      Utils.logMessage('job service in getAllRecentJobseekers: $error');
      return [];
    }
  }

  Future<List<LockedUser>> getAllLockedJobseekers() async {
    try {
      final result =
          await httpFetch('$databaseUrl/api/jobseeker/locked') as List<dynamic>;
      List<Map<String, dynamic>> users =
          result.map((e) => e as Map<String, dynamic>).toList();
      List<LockedUser> lockedUsersList =
          users.map((e) => LockedUser.fromJson(e)).toList();
      List<LockedUser> lockedJobseekersList = lockedUsersList
          .where((e) => e.userType == UserType.jobseeker)
          .toList();

      return lockedJobseekersList;
    } catch (error) {
      Utils.logMessage('job service in getAllLockedJobseekers: $error');
      return [];
    }
  }

  Future<LockedUser?> lockAccount(LockedUser lockedUser) async {
    try {
      final result = await httpFetch('$databaseUrl/api/jobseeker/lock',
          method: HttpMethod.post,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(lockedUser.toJson())) as Map<String, dynamic>;
      if (result['result'] != null) {
        final lockedUserMap = result['result'] as Map<String, dynamic>;
        return LockedUser.fromJson(lockedUserMap);
      } else {
        return null;
      }
    } catch (error) {
      Utils.logMessage('job service in lockAccount: $error');
      return null;
    }
  }

  Future<bool> unlockAccount(String userId) async {
    try {
      final result = await httpFetch(
          '$databaseUrl/api/jobseeker/$userId/unlock',
          method: HttpMethod.delete) as Map<String, dynamic>;
      final isUnlock = result['isUnlock'] as bool? ?? false;
      return isUnlock;
    } catch (error) {
      Utils.logMessage('job service in unlockAccount: $error');
      return false;
    }
  }

  Future<bool> deleteAccount(String userId) async {
    try {
      final result = await httpFetch(
          '$databaseUrl/api/jobseeker/$userId/delete',
          method: HttpMethod.delete) as Map<String, dynamic>;
      final isDeleted = result['isDeleted'] as bool? ?? false;
      return isDeleted;
    } catch (error) {
      Utils.logMessage('job service in deleteAccount: $error');
      return false;
    }
  }

  //Hàm tìm kiếm thông tin của một ứng viên cụ thể
  Future<Jobseeker?> findJobseekerById(String userId) async {
    try {
      final response = await httpFetch('$databaseUrl/api/jobseeker/$userId',
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          method: HttpMethod.get) as Map<String, dynamic>;
      final jobseeker = Jobseeker.fromJson(response);

      return jobseeker;
    } catch (error) {
      Utils.logMessage('job service: $error');
      return null;
    }
  }

  //Hàm tìm thông tin của một ứng viên đã khóa
  Future<LockedUser?> findLockedJobseekerById(String userId) async {
    try {
      final response = await httpFetch(
          '$databaseUrl/api/jobseeker/locked/$userId',
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          method: HttpMethod.get) as Map<String, dynamic>;
      final lockedUser = LockedUser.fromJson(response);
      return lockedUser;
    } catch (error) {
      Utils.logMessage('job service: $error');
      return null;
    }
  }

}
