import 'dart:async';
import 'dart:math';
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
  final JobpostingService _jobpostingService;
  SocketService? _socketService;

  List<Jobposting> _jobpostings = [];
  List<Jobposting> _filteredPosts = [];
  List<Jobposting> _searchResult = [];
  List<Jobposting> _companyPost = [];
  List<Jobposting> _filteredCompanyPosts = [];
  // List of suggested jobs from server
  List<Jobposting> _jobpostingSuggestion = [];
  bool _isLoading = false;

  JobpostingManager([AuthToken? authToken]) 
    : _jobpostingService = JobpostingService(authToken);

  // Getters
  List<Jobposting> get jobpostings => _jobpostings;
  List<Jobposting> get filteredPosts => _filteredPosts;
  List<Jobposting> get searchResults => _searchResult;
  List<Jobposting> get companyPosts => _companyPost;
  List<Jobposting> get filteredCompanyPosts => _filteredCompanyPosts;
  List<Jobposting> get jobpostingSuggestion => _jobpostingSuggestion;
  bool get isLoading => _isLoading;

  List<Jobposting> get favoriteJob => 
    _jobpostings.where((job) => job.isFavorite).toList();

  List<Jobposting> get notExpiredCompanyPost => _companyPost.where((post) {
    final deadline = DateTime.parse(post.deadline);
    return deadline.isAfter(DateTime.now());
  }).toList();

  List<Jobposting> get expiredCompanyPost => _companyPost.where((post) {
    final deadline = DateTime.parse(post.deadline);
    return deadline.isBefore(DateTime.now());
  }).toList();

  // Shuffle function to provide random suggestions
  List<Jobposting> get randomJobposting {
    final copy = List<Jobposting>.from(_jobpostings);
    copy.shuffle(Random());
    return copy;
  }

  // Setters
  set authToken(AuthToken? authToken) {
    _jobpostingService.authToken = authToken;
    notifyListeners();
  }

  set socketService(SocketService? socketService) {
    _socketService = socketService;
    notifyListeners();
  }

  // Public methods
  List<Jobposting> companyJobpostings(String companyId) {
    return _jobpostings.where((post) => post.company!.id == companyId).toList();
  }

  void jobpostingEventRunning() {
    Utils.logMessage("Jobposting event running, socket: $_socketService");
    _socketService?.socket?.on("jobposting:modified", (data) {
      Utils.logMessage("Processing jobposting socket event in JobpostingManager");
    });
  }

  Future<void> fetchJobposting() async {
    final jobpostings = await _jobpostingService.fetchJobpostingList();
    final suggestion = await _jobpostingService.fetchJobpostingSuggestionList();
    
    if (jobpostings != null && suggestion != null) {
      _jobpostings = jobpostings;
      _filteredPosts = _jobpostings;
      
      // Add jobs from suggestion list
      _jobpostingSuggestion = _jobpostings.where((jobpost) {
        return suggestion.any((suggestedJob) => suggestedJob.id == jobpost.id);
      }).toList();

      notifyListeners();
    }
  }

  void listenToJobpostingChanges() {
    Utils.logMessage("Called listenToJobpostingChanges in JobseekerHome");
    _socketService?.jobpostingStream.listen(
      _handleJobpostingUpdate,
      onError: (error) => Utils.logMessage("Error: $error")
    );
  }

  Future<void> changeFavoriteStatus(Jobposting jobposting) async {
    final savedState = jobposting.isFavorite;
    final isSuccess = await _jobpostingService.changeFavoriteState(
      !savedState, 
      jobposting.id
    );
    
    if (isSuccess) {
      jobposting.isFavorite = !savedState;
      notifyListeners();
    }
  }

  Future<void> filterJobposting(FilterType condition) async {
    final queryStr = _getFilterQueryString(condition);
    
    final filteredList = jobpostings.where((post) {
      final levels = post.level.map((e) => e.toLowerCase()).toList();
      return levels.contains(queryStr);
    }).toList();

    _filteredPosts = condition == FilterType.all ? jobpostings : filteredList;
    notifyListeners();
  }

  Future<void> search(String searchText) async {
    _isLoading = true;
    notifyListeners();

    _searchResult = jobpostings.where((post) {
      final normalizedPost = Utils.removeVietnameseAccent(post.toString());
      final normalizedSearch = Utils.removeVietnameseAccent(searchText);
      return normalizedPost.contains(normalizedSearch);
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCompanyPosts(String companyId) async {
    final companyPosts = await _jobpostingService.getCompanyJobposting(companyId);
    if (companyPosts != null) {
      _companyPost = companyPosts;
      _filteredCompanyPosts = _companyPost;
      notifyListeners();
    }
  }

  void filterCompanyPosts(TimeFilter condition) {
    _filteredCompanyPosts = switch (condition) {
      TimeFilter.all => _companyPost,
      TimeFilter.notExpired => notExpiredCompanyPost,
      TimeFilter.expired => expiredCompanyPost,
    };
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
      final index = companyPosts.indexWhere((job) => job.id == editedJob.id);
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

  // Private methods
  void _handleJobpostingUpdate(Map<String, dynamic> data) {
    final operationType = data["operationType"];
    final updatedJobposting = Jobposting.fromJson(data["modifiedJobposting"]);

    Utils.logMessage("Updating jobposting: $data");

    switch (operationType) {
      case "insert":
        _jobpostings.add(updatedJobposting);
      case "update":
        final index = _jobpostings.indexWhere((job) => job.id == updatedJobposting.id);
        if (index != -1) {
          _jobpostings[index] = updatedJobposting;
        } else {
          Utils.logMessage("Jobposting not found for update");
        }
      case "delete":
        _jobpostings.removeWhere((job) => job.id == updatedJobposting.id);
      default:
        Utils.logMessage("Unknown operation type: $operationType");
    }

    _filteredPosts = _jobpostings;
    notifyListeners();
  }

  String _getFilterQueryString(FilterType condition) => switch (condition) {
    FilterType.all => "all",
    FilterType.intern => "intern", 
    FilterType.fresher => "fresher",
    FilterType.junior => "junior",
    FilterType.middle => "middle",
    FilterType.senior => "senior",
    FilterType.manager => "manager",
    FilterType.leader => "leader",
  };
}
