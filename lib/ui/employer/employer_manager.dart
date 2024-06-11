import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:job_finder_app/services/node_service.dart';

import '../../models/auth_token.dart';
import '../../models/employer.dart';
import '../../services/employer_service.dart';

class EmployerManager extends ChangeNotifier {
  Employer _employer;

  final EmployerService _employerService;

  EmployerManager([Employer? employer, AuthToken? authToken])
      : _employer = employer!,
        _employerService = EmployerService(authToken);

  set authToken(AuthToken? authToken) {
    _employerService.authToken = authToken;
    notifyListeners();
  }

  set employer(Employer employer) {
    _employer = employer;
    notifyListeners();
  }

  Employer get employer => _employer;

  Future<void> fetchEmployerInfo() async {
    final employer = await _employerService.fetchEmployerInfo();
    if (employer != null) {
      _employer = employer;
      notifyListeners();
    }
  }

  Future<void> changeEmail(String password, String email) async {
    try {
      final result = await _employerService.changeEmail(password, email);
      if (result != null) {
        _employer.email = email;
        notifyListeners();
      }
    } catch (error) {
      log('Error in changeEmail - EmployerService: $error');
      return null;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final result =
          await _employerService.changePassword(oldPassword, newPassword);
      if (result == true) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      log('Error in changePassword - EmployerService: $error');
      return false;
    }
  }

  Future<void> updateProfile(Map<String, String> user, File? imageFile) async {
    //Thực hiện upload ảnh trước
    final result = await _employerService.updateProfile(user, imageFile);
    if (result != null) {
      employer.firstName = user['firstName']!;
      employer.lastName = user['lastName']!;
      employer.address = user['address']!;
      employer.phone = user['phone']!;
      employer.avatar = result['avatarLink'] ?? employer.avatar;
      notifyListeners();
    } else {
      log('Error in update profile - employerManager');
    }
  }
}
