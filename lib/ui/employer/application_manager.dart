import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/services/application_service.dart';

import '../../models/auth_token.dart';

class ApplicationManager extends ChangeNotifier {
  final ApplicationService _applicationService;

  ApplicationManager([AuthToken? authToken])
      : _applicationService = ApplicationService(authToken);

  set authToken(AuthToken? authToken) {
    _applicationService.authToken = authToken;
    notifyListeners();
  }

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
}
