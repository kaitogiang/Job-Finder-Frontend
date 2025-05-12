import 'dart:io';

import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/models/resume.dart';
import 'package:job_finder_app/services/jobseeker_service.dart';
import 'package:flutter/foundation.dart';
import 'package:job_finder_app/services/socket_service.dart';
import 'package:job_finder_app/ui/shared/enums.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

class JobseekerManager extends ChangeNotifier {
  Jobseeker _jobseeker;
  final JobseekerService _jobseekerService;
  SocketService? _socketService;

  JobseekerManager([Jobseeker? jobseeker, AuthToken? authToken])
      : _jobseeker = jobseeker!,
        _jobseekerService = JobseekerService(authToken);

  // Getters
  Jobseeker get jobseeker => _jobseeker;
  List<Resume> get resumes => _jobseeker.resume;
  List<String> get skills => _jobseeker.skills;

  // Setters
  set authToken(AuthToken? authToken) {
    _jobseekerService.authToken = authToken;
    Utils.logMessage('Gọi thay đổi ${authToken?.userId}');
    notifyListeners();
  }

  set jobseeker(Jobseeker? jobseeker) {
    _jobseeker = jobseeker!;
    Utils.logMessage('Gọi setJobseeker: ${jobseeker.toString()}');
    notifyListeners();
  }

  set socketService(SocketService? socketService) {
    _socketService = socketService;
    notifyListeners();
  }

  // Profile Management
  Future<void> fetchJobseekerInfo() async {
    final jobseeker = await _jobseekerService.fetchJobseekerInfo();
    if (jobseeker != null) {
      _jobseeker = jobseeker;
      notifyListeners();
    }
  }

  void modifyFirstName(String firstName) {
    jobseeker.firstName = firstName;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, String> user, File? imageFile) async {
    final result = await _jobseekerService.updateProfile(user, imageFile);

    if (result != null) {
      _updateJobseekerProfile(user, result['avatarLink']);
      notifyListeners();
    } else {
      Utils.logMessage('Lỗi trong hàm updateProfile của job manager');
    }
  }

  void _updateJobseekerProfile(Map<String, String> user, String? avatarLink) {
    jobseeker.firstName = user['firstName']!;
    jobseeker.lastName = user['lastName']!;
    jobseeker.address = user['address']!;
    if (avatarLink != null) {
      jobseeker.avatar = avatarLink;
    }
  }

  // Skills Management
  Future<void> appendSkills(List<String> skills) async {
    final updatedSkills = await _jobseekerService.appendSkills(skills);
    if (updatedSkills != null) {
      jobseeker.skills.addAll(skills);
      notifyListeners();
    } else {
      Utils.logMessage('Lỗi trong hàm appendSkill của job manager');
    }
  }

  Future<void> removeSkill(String skill) async {
    final result = await _jobseekerService.removeSkill(skill);
    if (result) {
      jobseeker.skills.remove(skill);
      notifyListeners();
    } else {
      Utils.logMessage('Lỗi trong hàm removeSkill của job manager');
    }
  }

  // Resume Management
  Future<void> uploadResume(String filename, File file) async {
    final result = await _jobseekerService.uploadResume(filename, file);
    if (result != null) {
      jobseeker.resume
        ..clear()
        ..addAll(result);
      notifyListeners();
    } else {
      Utils.logMessage('Lỗi trong hàm uploadResume của job manager');
    }
  }

  Future<bool> deleteResume(int index) async {
    final result = await _jobseekerService.deleteResume(index);
    if (result) {
      jobseeker.resume.removeAt(index);
      notifyListeners();
    } else {
      Utils.logMessage('Lỗi trong hàm removeResume của job manager');
    }
    return result;
  }

  // Experience Management
  Future<void> appendExperience(Map<String, String> data) async {
    try {
      final result = await _jobseekerService.appendExperience(data);
      if (result != null) {
        jobseeker.experience
          ..clear()
          ..addAll(result);
        notifyListeners();
      } else {
        Utils.logMessage('Lỗi trong hàm addExperience của job manager');
      }
    } catch (error) {
      Utils.logMessage('Lỗi trong hàm addExperience của job manager: $error');
    }
  }

  Future<void> removeExperience(int index) async {
    try {
      final result = await _jobseekerService.removeExperience(index);
      if (result) {
        jobseeker.experience.removeAt(index);
        notifyListeners();
      }
    } catch (error) {
      Utils.logMessage('Lỗi trong job manager $error');
    }
  }

  Future<void> updateExperience(int index, Map<String, String> data) async {
    try {
      final result = await _jobseekerService.updateExperience(index, data);
      if (result != null) {
        jobseeker.experience[index] = Experience(
          role: data['role']!,
          company: data['company']!,
          duration: data['from']! + data['to']!,
        );
        notifyListeners();
      }
    } catch (error) {
      Utils.logMessage('Lỗi trong hàm updateExperience của job manager: $error');
    }
  }

  // Education Management
  Future<void> addEducation(Education edu) async {
    try {
      final result = await _jobseekerService.addEducation(edu);
      if (result != null) {
        jobseeker.education.add(edu);
        notifyListeners();
      }
    } catch (error) {
      Utils.logMessage('Lỗi trong hàm addEducation của job manager: $error');
    }
  }

  Future<void> removeEducation(int index) async {
    try {
      final result = await _jobseekerService.removeEducation(index);
      if (result) {
        jobseeker.education.removeAt(index);
        notifyListeners();
      }
    } catch (error) {
      Utils.logMessage('Lỗi trong hàm removeEducation của job manager: $error');
    }
  }

  Future<void> updateEducation(int index, Education education) async {
    try {
      final result = await _jobseekerService.updateEducation(index, education);
      if (result != null) {
        jobseeker.education[index] = education;
        notifyListeners();
      }
    } catch (error) {
      Utils.logMessage('Lỗi trong hàm updateEducation của job manager: $error');
    }
  }

  // Account Management
  Future<bool> changeEmail(String password, String email) async {
    try {
      final result = await _jobseekerService.changeEmail(password, email);
      if (result != null) {
        jobseeker.email = email;
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      Utils.logMessage('Lỗi trong hàm changeEmail của job manager: $error');
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final result = await _jobseekerService.changePassword(oldPassword, newPassword);
      if (result == true) {
        Utils.logMessage('JobManager: Đổi mật khẩu thành công');
        return true;
      }
      return false;
    } catch (error) {
      Utils.logMessage('Lỗi trong hàm changePassword của job manager: $error');
      return false;
    }
  }

  // User Behavior Tracking
  void _observeUserAction(BehaviourType type, String jobseekerId, Map<String, dynamic> metaData) {
    _socketService?.observeUserAction(type, jobseekerId, metaData);
  }

  void observeViewJobPostAction(String jobseekerId, String jobpostingId) {
    _observeUserAction(BehaviourType.viewJobPost, jobseekerId, {'jobpostingId': jobpostingId});
  }

  void observeSaveJobPostAction(String jobseekerId, String jobpostingId) {
    _observeUserAction(BehaviourType.saveJobPost, jobseekerId, {'jobpostingId': jobpostingId});
  }

  void observeSearchJobPostAction(String jobseekerId, String searchQuery) {
    _observeUserAction(BehaviourType.searchJobPost, jobseekerId, {'searchQuery': searchQuery});
  }

  void observeSearchCompanyAction(String jobseekerId, String searchQuery) {
    _observeUserAction(BehaviourType.searchCompany, jobseekerId, {'searchQuery': searchQuery});
  }

  void observeViewCompanyAction(String jobseekerId, String companyId) {
    _observeUserAction(BehaviourType.viewCompany, jobseekerId, {'companyId': companyId});
  }

  void observeFilterJobPostAction(String jobseekerId, String filterOption) {
    _observeUserAction(BehaviourType.filterJobPost, jobseekerId, {'filterOption': filterOption});
  }
}
