import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/services/jobseeker_service.dart';

class JobseekerManager extends ChangeNotifier {
  Jobseeker _jobseeker;

  final JobseekerService _jobseekerService;

  JobseekerManager([Jobseeker? jobseeker, AuthToken? authToken])
      : _jobseeker = jobseeker!,
        _jobseekerService = JobseekerService(authToken);

  set authToken(AuthToken? authToken) {
    _jobseekerService.authToken = authToken;
  }

  Jobseeker get jobseeker => _jobseeker;

  List<String> get skills => _jobseeker.skills;

  void addSkill(String skill) {
    skills.add(skill);
    notifyListeners();
  }

  void removeSkill(String skill) {
    skills.remove(skill);
    notifyListeners();
  }

  void modifyFirstName(String firstName) {
    jobseeker.firstName = firstName;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, String> user, File? imageFile) async {
    //Thực hiện upload ảnh trước
    final result = await _jobseekerService.updateProfile(user, imageFile);

    if (result != null) {
      jobseeker.firstName = user['firstName']!;
      jobseeker.lastName = user['lastName']!;
      jobseeker.address = user['address']!;
      jobseeker.avatar = result['avatarLink'] ?? jobseeker.avatar;
      notifyListeners();
    } else {
      log('Lỗi trong hàm updateProfile của job manager');
    }
  }
}
