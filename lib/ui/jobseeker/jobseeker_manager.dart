import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/services/auth_service.dart';
import 'package:job_finder_app/services/jobseeker_service.dart';
import 'package:flutter/foundation.dart';

import '../../models/resume.dart';

class JobseekerManager extends ChangeNotifier {
  Jobseeker _jobseeker;

  final JobseekerService _jobseekerService;

  JobseekerManager([Jobseeker? jobseeker, AuthToken? authToken])
      : _jobseeker = jobseeker!,
        _jobseekerService = JobseekerService(authToken);

  set authToken(AuthToken? authToken) {
    _jobseekerService.authToken = authToken;
    log('Gọi thay đổi');
    notifyListeners();
  }

  set jobseeker(Jobseeker jobseeker) {
    _jobseeker = jobseeker;
    notifyListeners();
  }

  Jobseeker get jobseeker => _jobseeker;

  List<String> get skills => _jobseeker.skills;

  Future<void> fetchJobseekerInfo() async {
    final jobseeker = await _jobseekerService.fetchJobseekerInfo();
    if (jobseeker != null) {
      _jobseeker = jobseeker;
    }
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

  Future<void> appendSkills(List<String> skills) async {
    final updatedSkils = await _jobseekerService.appendSkills(skills);
    if (updatedSkils != null) {
      jobseeker.skills.addAll(skills);
      notifyListeners();
    } else {
      log('Lỗi trong hàm appendSkill của job manager');
    }
  }

  Future<void> removeSkill(String skill) async {
    final result = await _jobseekerService.removeSkill(skill);
    //TODO Nếu result = true có nghĩa là xóa trên database thành công thì cập nhật UI
    //TODO và báo cập nhật giao diện
    if (result) {
      jobseeker.skills.remove(skill);
      notifyListeners();
    } else {
      log('Lỗi trong hàm removeSkill của job manager');
    }
  }

  //todo Hàm thực thi việc upload cv cho server
  Future<void> uploadResume(String filename, File file) async {
    final result = await _jobseekerService.uploadResume(filename, file);
    if (result != null) {
      jobseeker.resume.clear();
      jobseeker.resume.add(result);
      notifyListeners();
    } else {
      log('Lỗi trong hàm uploadResume của job manager');
    }
  }

  //todo hàm xóa file cv
  Future<bool> deleteResume() async {
    final result = await _jobseekerService.deleteResume();
    if (result) {
      jobseeker.resume.clear();
      notifyListeners();
    } else {
      log('Lỗi trong hàm removeResume của job manager');
    }
    return result;
  }
}
