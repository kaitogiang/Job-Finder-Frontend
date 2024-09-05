import 'dart:async';
import 'dart:math';
import 'dart:developer' as dp;
import 'package:flutter/material.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/jobposting_service.dart';
import 'package:job_finder_app/services/socket_service.dart';
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

enum TimeFilter {
  all,
  notExpired,
  expired,
}

class JobpostingManager extends ChangeNotifier {
  List<Jobposting> _jobpostings = [];
  List<Jobposting> _filteredPosts = [];
  List<Jobposting> _searchResult = [];
  List<Jobposting> _companyPost = [];
  List<Jobposting> _filteredCompanyPosts = [];

  // final ValueNotifier<List<Jobposting>> _randomJobpostingNotifier =
  //     ValueNotifier([]);

  bool _isLoading = false;

  final JobpostingService _jobpostingService;
  SocketService? _socketService;

  JobpostingManager([AuthToken? authToken])
      : _jobpostingService = JobpostingService(authToken);

  set authToken(AuthToken? authToken) {
    _jobpostingService.authToken = authToken;
    notifyListeners();
  }

  set socketService(SocketService? socketService) {
    _socketService = socketService;
    // _socketService?.listenToJobpostingChanges(_printSocketEvent);
    notifyListeners();
  }

  void jobpostingEventRunning() {
    Utils.logMessage("Jobposting event running, socket: ${_socketService}");

    _socketService?.socket?.on("jobposting:modified", (data) {
      Utils.logMessage("Xu ly jobposting socket event trong JobpostinManager");
    });
  }

  void _printSocketEvent(Map<String, dynamic> data) {
    Utils.logMessage("Printout socket event");
  }

  List<Jobposting> get jobpostings => _jobpostings;

  List<Jobposting> get filteredPosts => _filteredPosts;

  List<Jobposting> get searchResults => _searchResult;

  bool get isLoading => _isLoading;

  // List<Jobposting> get randomJobposting => _randomJobpostingNotifier.value;

  List<Jobposting> get favoriteJob {
    return _jobpostings.where((job) => job.isFavorite).toList();
  }

  // List<Jobposting> get companyPosts => _jobpostings;
  List<Jobposting> get companyPosts => _companyPost;

  List<Jobposting> get filteredCompanyPosts => _filteredCompanyPosts;

  List<Jobposting> get notExpiredCompanyPost {
    return _companyPost.where((post) {
      final deadline = DateTime.parse(post.deadline);
      return deadline.isAfter(DateTime.now());
    }).toList();
  }

  List<Jobposting> get expiredCompanyPost {
    return _companyPost.where((post) {
      final deadline = DateTime.parse(post.deadline);
      return deadline.isBefore(DateTime.now());
    }).toList();
  }

  // todo Hàm xáo trộn để đưa ra gợi ý ngẫu nhiên
  List<Jobposting> get randomJobposting {
    List<Jobposting> copy = [];
    for (int i = 0; i < _jobpostings.length; i++) {
      copy.add(_jobpostings[i]);
    }
    copy.shuffle(Random());
    return copy;
  }

  // void _updateRandomJobposting() {
  //   List<Jobposting> copy = List.from(_jobpostings);
  //   copy.shuffle(Random());
  //   _randomJobpostingNotifier.value = copy;
  // }

  List<Jobposting> companyJobpostings(String companyId) {
    return _jobpostings.where((post) => post.company!.id == companyId).toList();
  }

  Future<void> fetchJobposting() async {
    final jobpostings = await _jobpostingService.fetchJobpostingList();
    if (jobpostings != null) {
      dp.log('Trong Jobmanager, da nap: ${jobpostings.length}');
      _jobpostings = jobpostings;
      _filteredPosts = _jobpostings;
      notifyListeners();
    }
  }

  void _handleJobpostingUpdate(Map<String, dynamic> data) {
    final operationType = data["operationType"];
    final updatedJobposting = Jobposting.fromJson(data["modifiedJobposting"]);
    Utils.logMessage("Cập nhật lại update jobposting: $data");
    if (operationType == "insert") {
      _jobpostings.add(updatedJobposting);
    } else if (operationType == "update") {
      final index =
          _jobpostings.indexWhere((job) => job.id == updatedJobposting.id);
      _jobpostings[index] = updatedJobposting;
    } else if (operationType == "delete") {
      _jobpostings.removeWhere((job) => job.id == updatedJobposting.id);
    } else {
      Utils.logMessage("Unknown operation type: $operationType");
    }

    _filteredPosts = _jobpostings;
    notifyListeners();
  }

  void listenToJobpostingChanges() {
    Utils.logMessage("Goi listenToJobpostingChanges trong JobseekerHome");
    _socketService?.jobpostingStream.listen((data) {
      _handleJobpostingUpdate(data);
    }, onError: (error) {
      Utils.logMessage("Error: $error");
    });
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
      _filteredCompanyPosts = _companyPost;
      notifyListeners();
    }
  }

  void filterCompanyPosts(TimeFilter condition) {
    List<Jobposting> filteredList = switch (condition) {
      TimeFilter.all => _companyPost,
      TimeFilter.notExpired => notExpiredCompanyPost,
      TimeFilter.expired => expiredCompanyPost,
    };
    _filteredCompanyPosts = filteredList;
    notifyListeners();
  }

  Future<void> createJobposting(Jobposting job) async {
    final newJob = await _jobpostingService.createJobposting(job);
    if (newJob != null) {
      _companyPost.add(newJob);
      notifyListeners();
    }
  }

  Future<void> updateJobposting(Jobposting editedJob) async {
    final updatedJob = await _jobpostingService.updatePost(editedJob);
    if (updatedJob != null) {
      int index = companyPosts.indexWhere((job) => job.id == editedJob.id);
      _companyPost[index] = updatedJob;
      notifyListeners();
    }
  }

  Future<void> deleteJobposting(String id) async {
    final isDeleted = await _jobpostingService.deletePost(id);
    if (isDeleted) {
      _companyPost.removeWhere((job) => job.id == id);
      notifyListeners();
    }
  }
}
