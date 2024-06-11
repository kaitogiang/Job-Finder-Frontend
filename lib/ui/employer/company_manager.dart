import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/company_service.dart';

import '../../models/company.dart';

class CompanyManager extends ChangeNotifier {
  Company? _company;

  final CompanyService _companyService;

  CompanyManager([AuthToken? authToken])
      : _companyService = CompanyService(authToken);

  set authToken(AuthToken? authToken) {
    _companyService.authToken = authToken;
    notifyListeners();
  }

  Company? get company => _company;

  Future<void> fetchCompanyInfo() async {
    final company = await _companyService.fetchCompanyInfo();
    if (company != null) {
      log('Gia tri la: ${company.policy}');
      _company = company;
      notifyListeners();
    }
  }

  Future<void> updateCompany(
      Company editedCompany, File? file, List<File> images) async {
    final updatedCompany =
        await _companyService.updateCompanyInfo(file, images, editedCompany);
    if (updatedCompany != null) {
      _company = updatedCompany;
      notifyListeners();
    }
  }
}
