import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/models/application.dart';
import 'package:job_finder_app/services/application_service.dart';

import '../../models/application_storage.dart';
import '../../models/auth_token.dart';
import '../../models/jobseeker.dart';

class ApplicationManager extends ChangeNotifier {
  List<ApplicationStorage> _applicationStorage = [];

  final ApplicationService _applicationService;

  ApplicationManager([AuthToken? authToken])
      : _applicationService = ApplicationService(authToken);

  set authToken(AuthToken? authToken) {
    _applicationService.authToken = authToken;
    notifyListeners();
  }

  List<ApplicationStorage> get applicationStorage => _applicationStorage;

  ApplicationStorage applicationStorageById(String id) =>
      _applicationStorage.firstWhere((app) => app.id == id);

  Future<String?> downloadFile(String url, String fileName) async {
    try {
      final downloadPath =
          await _applicationService.downloadFile(url, fileName);
      if (downloadPath != null) {
        return downloadPath;
      }
      return null;
    } catch (error) {
      log('Error in Application Manager - downloadFile $error');
      return null;
    }
  }

  //? Hàm nạp tất cả các nơi chứa hồ sơ ứng tuyển của từng bài viết
  Future<void> fetchApplicationStorage() async {
    try {
      final result = await _applicationService.getAllPostApplicationList();
      if (result != null) {
        _applicationStorage = result;
        notifyListeners();
      }
    } catch (error) {
      log('Error in Application Manager - fetchApplicationStorage $error');
    }
  }

  //? Hàm ứng tuyển vào công việc
  Future<bool> applyApplication(
      String jobpostingId, String jobseekerId, String employerEmail) async {
    try {
      final result = await _applicationService.applyApplication(
          jobpostingId, jobseekerId, employerEmail);
      if (result) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      log('Error in Application Manager - applyApplication $error');
      return false;
    }
  }

  //?Hàm chập nhận một hồ sơ
  Future<void> acceptApplication(
      String jobpostingId, Application userApplication) async {
    try {
      final result = await _applicationService.acceptApplication(
          jobpostingId, userApplication.jobseekerId);
      if (result) {
        userApplication.status = 1;
        notifyListeners();
      }
    } catch (error) {
      log('Error in Application Manager - acceptApplication $error');
    }
  }

  //?Hàm từ chối một hồ sơ
  Future<void> rejectApplication(
      String jobpostingId, Application userApplication) async {
    try {
      final result = await _applicationService.rejectApplication(
          jobpostingId, userApplication.jobseekerId);
      if (result) {
        userApplication.status = 2;
        notifyListeners();
      }
    } catch (error) {
      log('Error in Application Manager - acceptApplication $error');
    }
  }

  //?Hàm tìm một ứng viên bất kỳ
  Future<Jobseeker?> getJobseekerById(String id) async {
    final jobseeker = await _applicationService.fetchJobseekerById(id);
    if (jobseeker != null) {
      return jobseeker;
    }
    return null;
  }
}
