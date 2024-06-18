import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/jobposting_service.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

import '../../models/jobposting.dart';

enum FilterType {
  all,
  intern,
  fresher,
  junior,
  middle,
  senior,
  manager,
  leader,
}

class JobpostingManager extends ChangeNotifier {
  List<Jobposting> _jobpostings = [];
  List<Jobposting> _filteredPosts = [];
  List<Jobposting> _searchResult = [];
  List<Jobposting> _companyPost = [];

  bool _isLoading = false;

  final JobpostingService _jobpostingService;

  JobpostingManager([AuthToken? authToken])
      : _jobpostingService = JobpostingService(authToken);

  set authToken(AuthToken? authToken) {
    _jobpostingService.authToken = authToken;
    notifyListeners();
  }

  List<Jobposting> get jobpostings => _jobpostings;

  List<Jobposting> get filteredPosts => _filteredPosts;

  List<Jobposting> get searchResults => _searchResult;

  bool get isLoading => _isLoading;

  List<Jobposting> get favoriteJob {
    return _jobpostings.where((job) => job.isFavorite).toList();
  }

  List<Jobposting> get companyPosts => _jobpostings;

  //todo Hàm xáo trộn để đưa ra gợi ý ngẫu nhiên
  List<Jobposting> get randomJobposting {
    List<Jobposting> copy = [];
    for (int i = 0; i < _jobpostings.length; i++) {
      copy.add(_jobpostings[i]);
    }
    copy.shuffle(Random());
    return copy;
  }

  List<Jobposting> companyJobpostings(String companyId) {
    return _jobpostings.where((post) => post.company!.id == companyId).toList();
  }

  Future<void> fetchJobposting() async {
    final jobpostings = await _jobpostingService.fetchJobpostingList();
    if (jobpostings != null) {
      _jobpostings = jobpostings;
      _filteredPosts = _jobpostings;
      notifyListeners();
    }
  }

  Future<void> changeFavoriteStatus(Jobposting jobposting) async {
    final savedState = jobposting.isFavorite;
    final isSuccess = await _jobpostingService.changeFavoriteState(
        !savedState, jobposting.id);
    if (isSuccess) {
      jobposting.isFavorite = !savedState;
      notifyListeners();
    }
  }

  Future<void> filterJobposting(FilterType condition) async {
    String queryStr = switch (condition) {
      FilterType.all => "tất cả",
      FilterType.intern => "intern",
      FilterType.fresher => "fresher",
      FilterType.junior => "junior",
      FilterType.middle => "middle",
      FilterType.senior => "senior",
      FilterType.manager => "manager",
      FilterType.leader => "leader",
    };
    final filteredList = jobpostings.where((post) {
      List<String> level = post.level.map((e) => e.toLowerCase()).toList();
      return level.contains(queryStr);
    }).toList();

    if (condition == FilterType.all) {
      _filteredPosts = jobpostings;
    } else {
      _filteredPosts = filteredList;
    }
    notifyListeners();
  }

  Future<void> search(String searchTex) async {
    _isLoading = true;
    notifyListeners();
    _searchResult = jobpostings.where((post) {
      String removedAccentPost = Utils.removeVietnameseAccent(post.toString());
      String removedAccentSearch = Utils.removeVietnameseAccent(searchTex);
      return removedAccentPost.contains(removedAccentSearch);
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCompanyPosts(String companyId) async {
    final companyPosts =
        await _jobpostingService.getCompanyJobposting(companyId);
    if (companyPosts != null) {
      _companyPost = companyPosts;
      print('CompanyPost la: ${_companyPost.length}');
      notifyListeners();
    }
  }
}
