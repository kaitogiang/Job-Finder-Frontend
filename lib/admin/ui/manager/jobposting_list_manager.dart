import 'package:flutter/foundation.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/services/jobposting_service.dart';

class JobpostingListManager with ChangeNotifier {
  List<Jobposting> _jobpostings = [];
  List<Jobposting> _filteredJobpostings = [];
  List<Jobposting> _mostFavoriteJobpostings = [];
  bool _isLoading = false;
  String _errorMessage = '';

  //khởi tạo dịch vụ
  final JobpostingService _jobpostingService;

  List<Jobposting> get jobpostings => _jobpostings;
  List<Jobposting> get filteredJobpostings => _filteredJobpostings;
  List<Jobposting> get mostFavoriteJobpostings => _mostFavoriteJobpostings;

  int get mostFavoriteJobpostingsCount => _mostFavoriteJobpostings.length;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  int get jobpostingsCount => _jobpostings.length;

  set authToken(AuthToken? authToken) {
    _jobpostingService.authToken = authToken;
    notifyListeners();
  }

  JobpostingListManager([AuthToken? authToken])
      : _jobpostingService = JobpostingService(authToken);

  //Hàm lấy danh sách ứng viên theo nhóm 5 người, pageNumber là số thứ tự nhóm đó bắt đầu từ 1
  //Ví dụ: pageNumber = 1 -> lấy nhóm 1, pageNumber = 2 -> lấy nhóm 2, ...
  //PageNumber - 1 tương đương với index bắt đầu của nhóm 5 người.
  List<Jobposting> getJobpostingByPage(
      int pageNumber, int groupSize, List<Jobposting> list) {
    int startIndex = (pageNumber - 1) * groupSize;
    int endIndex = (startIndex + groupSize) > list.length
        ? list.length
        : startIndex + groupSize;
    return list.sublist(startIndex, endIndex);
  }

  //Hàm lấy số lượng nhóm có thể hiển thị trong number pagination,
  //hàm này tự động làm tròn lên số lớn hơn nếu có phần dư
  //Ví dụ 0.1 -> 1, 0.5 -> 1, 0.9 -> 1
  int getTotalGroupCount(int groupSize, List<Jobposting> list) {
    return (list.length / groupSize).ceil();
  }



  Future<void> fetchJobpostings() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // TODO: Implement API call to fetch jobpostings
      // For now, we'll just simulate a delay
      await Future.delayed(Duration(seconds: 2));

      // Placeholder data
      _jobpostings = [
        // Add some dummy Jobposting objects here
      ];
    } catch (error) {
      _errorMessage = 'Failed to fetch jobpostings: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addJobposting(Jobposting jobposting) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call to add a jobposting
      await Future.delayed(Duration(seconds: 1));
      _jobpostings.add(jobposting);
    } catch (error) {
      _errorMessage = 'Failed to add jobposting: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateJobposting(Jobposting jobposting) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call to update a jobposting
      await Future.delayed(Duration(seconds: 1));
      final index = _jobpostings.indexWhere((jp) => jp.id == jobposting.id);
      if (index != -1) {
        _jobpostings[index] = jobposting;
      }
    } catch (error) {
      _errorMessage = 'Failed to update jobposting: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteJobposting(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement API call to delete a jobposting
      await Future.delayed(Duration(seconds: 1));
      _jobpostings.removeWhere((jp) => jp.id == id);
    } catch (error) {
      _errorMessage = 'Failed to delete jobposting: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchJobpostings(String searchText) {
    // TODO: Implement search functionality
    // This could be a local search or an API call depending on your requirements
    notifyListeners();
  }

  List<Jobposting> sortJobpostingsByFavoriteCount(List<Jobposting> jobpostings) {
    // Assuming Jobposting has a field named favoriteCount for demonstration
    // This is a placeholder for actual sorting logic
    return jobpostings;
  }
}
