import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/company.dart';
import 'package:job_finder_app/models/employer.dart';
import 'package:job_finder_app/models/locked_users.dart';

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

  //Hàm lấy tất cả các Employer
  Future<List<Employer>> getAllEmployers() async {
    try {
      final response = await httpFetch('$databaseUrl/api/employer/',
          headers: headers, method: HttpMethod.get) as List<dynamic>;
      final employersMap = List<Map<String, dynamic>>.from(response);
      final employers =
          employersMap.map((employer) => Employer.fromJson(employer)).toList();
      return employers;
    } catch (error) {
      Utils.logMessage('Error in getAllEmployers method of Employer: $error');
      return [];
    }
  }

  //Hàm lấy tất cả những doanh nghiệp vừa đăng ký tài khoản
  Future<List<Employer>> getAllRecentEmployers() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/employer/recent',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      final employersMap = List<Map<String, dynamic>>.from(response);
      final employers =
          employersMap.map((employer) => Employer.fromJson(employer)).toList();
      return employers;
    } catch (error) {
      Utils.logMessage(
          'Error in getAllRecentEmployers method of Employer: $error');
      return [];
    }
  }

  Future<List<LockedUser>> getAllLockedEmployers() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/employer/locked',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      final lockedEmployersMap = List<Map<String, dynamic>>.from(response);
      List<LockedUser> lockedUsersList = lockedEmployersMap
          .map((userMap) => LockedUser.fromJson(userMap))
          .toList();
      List<LockedUser> lockedEmployersList = lockedUsersList
          .where((user) => user.userType == UserType.employer)
          .toList();
      return lockedEmployersList;
    } catch (error) {
      Utils.logMessage(
          'Error in getAllLockedEmployers method of Employer: $error');
      return [];
    }
  }

  Future<LockedUser?> lockAccount(LockedUser lockedUser) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/employer/lock',
        headers: headers,
        method: HttpMethod.post,
        body: jsonEncode(lockedUser.toJson()),
      ) as Map<String, dynamic>;
      if (result['result'] != null) {
        final lockedUserMap = result['result'] as Map<String, dynamic>;
        return LockedUser.fromJson(lockedUserMap);
      }
      return null;
    } catch (error) {
      Utils.logMessage('Error in lockAccount method of Employer: $error');
      return null;
    }
  }

  Future<bool> unlockAccount(String userId) async {
    Utils.logMessage('Goi unlock');
    try {
      final result = await httpFetch(
        '$databaseUrl/api/employer/$userId/unlock',
        method: HttpMethod.delete,
      ) as Map<String, dynamic>;
      Utils.logMessage('result: $result');
      final isUnlock = result['isUnlock'] as bool? ?? false;
      return isUnlock;
    } catch (error) {
      Utils.logMessage('Error in unlockAccount method of Employer: $error');
      return false;
    }
  }

  Future<bool> checkLockedAccount(String userId) async {
    try {
      final result = await httpFetch(
        '$databaseUrl/api/employer/$userId/check-locked',
        method: HttpMethod.get,
      ) as Map<String, dynamic>;
      final isLocked = result['isLocked'] as bool? ?? false;
      return isLocked;
    } catch (error) {
      Utils.logMessage(
          'Errror in CheckLockedAccount of EmployerService: $error');
      return false;
    }
  }

  //Hàm lấy thông tin tài khoản của một employer dựa vào userId
  Future<Employer?> getEmployerById(String userId) async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/employer/$userId',
        headers: headers,
        method: HttpMethod.get,
      ) as Map<String, dynamic>;
      final employer = Employer.fromJson(response);
      return employer;
    } catch (error) {
      Utils.logMessage(
          'Error in getEmployerById method of EmployerService: $error');
      return null;
    }
  }

  //Hàm tìm company dựa vào EmployerId
  Future<Company?> getCompanyByEmployerId(String employerId) async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/employer/$employerId/company',
        headers: headers,
        method: HttpMethod.get,
      ) as Map<String, dynamic>;
      final company = Company.fromJson(response);
      return company;
    } catch (error) {
      Utils.logMessage('Error in getCompanyByEmployerId: $error');
      return null;
    }
  }
}
