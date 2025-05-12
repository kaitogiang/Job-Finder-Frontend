import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/models/application.dart';
import 'package:job_finder_app/services/application_service.dart';

import '../../models/application_storage.dart';
import '../../models/auth_token.dart';
import '../../models/employer.dart';
import '../../models/jobseeker.dart';

class ApplicationManager extends ChangeNotifier {
  List<ApplicationStorage> _applicationStorage = [];
  List<ApplicationStorage> _userApplicationStorage = [];

  final ApplicationService _applicationService;

  ApplicationManager([AuthToken? authToken])
      : _applicationService = ApplicationService(authToken);

  set authToken(AuthToken? authToken) {
    _applicationService.authToken = authToken;
    notifyListeners();
  }

  List<ApplicationStorage> get applicationStorage => _applicationStorage;

  List<ApplicationStorage> get userApplicationStorage {
    _userApplicationStorage.sort((a, b) =>
        a.applications.first.status.compareTo(b.applications.first.status));
    return _userApplicationStorage;
  }

  ApplicationStorage getApplicationStorageById(String id) =>
      _applicationStorage.firstWhere((app) => app.id == id);

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

  void sortApplicationsList(List<Application> list) {
    list.sort((a, b) => a.status.compareTo(b.status));
  }

  //? Function to load all application storage of each post
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

  //? Function to load all applications submitted by the user
  Future<void> fetchJobseekerApplication() async {
    try {
      final result = await _applicationService.fetchJobseekerApplication();
      if (result != null) {
        _userApplicationStorage = result;
        notifyListeners();
      }
    } catch (error) {
      log('Error in Application Manager - fetchJobseekerApplication $error');
    }
  }

  //? Function to apply for a job
  Future<bool> applyApplication(
      String jobpostingId, String employerEmail, String resumeLink) async {
    try {
      final result = await _applicationService.applyApplication(
          jobpostingId, employerEmail, resumeLink);
      if (result) {
        final applicationStorage =
            await _applicationService.fetchJobseekerApplication();
        if (applicationStorage != null) {
          _userApplicationStorage = applicationStorage;
          notifyListeners();
        }
        return true;
      } else {
        return false;
      }
    } catch (error) {
      log('Error in Application Manager - applyApplication $error');
      return false;
    }
  }

  //? Function to accept an application
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

  //? Function to reject an application
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

  //? Function to find a jobseeker
  Future<Jobseeker?> getJobseekerById(String id) async {
    final jobseeker = await _applicationService.fetchJobseekerById(id);
    if (jobseeker != null) {
      return jobseeker;
    }
    return null;
  }

  Future<void> approveApplication(
      Application application, String jobpostingId) async {
    try {
      final result = await _applicationService.acceptApplication(
          jobpostingId, application.jobseekerId);
      if (result) {
        application.status = 1;
        notifyListeners();
      }
    } catch (error) {
      log('Error in Application Manager - approveApplication $error');
    }
  }

  Future<Employer?> getEmployerByCompanyId(String companyId) async {
    try {
      final employer =
          await _applicationService.getEmployerByCompanyId(companyId);
      if (employer != null) {
        return employer;
      }
      return null;
    } catch (error) {
      log('Error in Application Manager - getEmployerByCompanyId $error');
      return null;
    }
  }
}
