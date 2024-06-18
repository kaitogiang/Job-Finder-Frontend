import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/company_service.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

import '../../models/company.dart';

class CompanyManager extends ChangeNotifier {
  Company? _company;
  List<Company> _all = [];
  List<Company> searchResults = [];

  final CompanyService _companyService;

  CompanyManager([AuthToken? authToken])
      : _companyService = CompanyService(authToken);

  set authToken(AuthToken? authToken) {
    _companyService.authToken = authToken;
    notifyListeners();
  }

  Company? get company => _company;

  List<Company> get allCompanies => _all;

  Future<void> fetchAllCompanies() async {
    _all = await _companyService.fetchAllCompanies();
    searchResults = _all;
    notifyListeners();
  }

  void search(String searchText) {
    if (searchText.isEmpty) {
      searchResults = _all;
      notifyListeners();
      return;
    }

    searchResults = _all.where((company) {
      String companyString =
          Utils.removeVietnameseAccent(company.toString()).toLowerCase();
      String noAccentSearchText =
          Utils.removeVietnameseAccent(searchText).toLowerCase();

      return companyString.contains(noAccentSearchText);
    }).toList();
    notifyListeners();
  }

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
