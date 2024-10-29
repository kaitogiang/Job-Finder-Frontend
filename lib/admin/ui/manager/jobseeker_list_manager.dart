import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/utils/vietname_provinces.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/models/locked_users.dart';
import 'package:job_finder_app/services/jobseeker_service.dart';

class JobseekerListManager extends ChangeNotifier {
  // final List<Map<String, dynamic>> _jobseekersList = jobseekers;
  List<Jobseeker> _jobseekersList = [];
  List<Jobseeker> _recentJobseekersList = [];
  List<LockedUser> _lockedJobseekersList = [];
  List<Jobseeker> _filteredJobseekersList = [];

  //khởi tạo dịch vụ
  final JobseekerService _jobseekerService;

  JobseekerListManager([AuthToken? authToken])
      : _jobseekerService = JobseekerService(authToken);

  set authToken(AuthToken? authToken) {
    _jobseekerService.authToken = authToken;
    Utils.logMessage('Cập nhật authToken cho JobseerService');
    notifyListeners();
  }

  List<Jobseeker> getJobseekers() => _jobseekersList;

  List<Jobseeker> get filteredJobseekers => _filteredJobseekersList;

  List<Jobseeker> get jobseekerList => _jobseekersList;

  List<Jobseeker> get recentJobseekersList => _recentJobseekersList;

  List<Jobseeker> get lockedJobseekersList => _jobseekersList
      .where(
          (e) => _lockedJobseekersList.any((locked) => locked.userId == e.id))
      .toList();

  set jobseekerList(List<Jobseeker> list) {
    _jobseekersList = list;
  }

  //Hàm lấy số lượng phần tử trong danh sách
  int get getJobseekersCount => _jobseekersList.length;

  int get getFilteredJobseekersCount => _filteredJobseekersList.length;
  int get getRecentJobseekersCount => _recentJobseekersList.length;

  int get getLockedJobseekersCount => _lockedJobseekersList.length;

  int get activeJobseekersCount =>
      getJobseekersCount - getLockedJobseekersCount;

  //Hàm lấy danh sách ứng viên theo nhóm 5 người, pageNumber là số thứ tự nhóm đó bắt đầu từ 1
  //Ví dụ: pageNumber = 1 -> lấy nhóm 1, pageNumber = 2 -> lấy nhóm 2, ...
  //PageNumber - 1 tương đương với index bắt đầu của nhóm 5 người.
  List<Jobseeker> getJobseekerByPage(
      int pageNumber, int groupSize, List<Jobseeker> list) {
    int startIndex = (pageNumber - 1) * groupSize;
    int endIndex = (startIndex + groupSize) > list.length
        ? list.length
        : startIndex + groupSize;
    return list.sublist(startIndex, endIndex);
  }

  //Hàm lấy số lượng nhóm có thể hiển thị trong number pagination,
  //hàm này tự động làm tròn lên số lớn hơn nếu có phần dư
  //Ví dụ 0.1 -> 1, 0.5 -> 1, 0.9 -> 1
  int getTotalGroupCount(int groupSize, List<Jobseeker> list) {
    return (list.length / groupSize).ceil();
  }

  //hàm nạp tất cả các jobseeker
  Future<void> getAllJobseekers() async {
    try {
      List<Jobseeker> jobseekers = await _jobseekerService.getAllJobseekers();
      List<Jobseeker> recentJobseekers =
          await _jobseekerService.getAllRecentJobseekers();
      List<LockedUser> lockedJobseekers =
          await _jobseekerService.getAllLockedJobseekers();
      jobseekerList = jobseekers;
      _filteredJobseekersList = [...jobseekers];
      _recentJobseekersList = recentJobseekers;
      _lockedJobseekersList = lockedJobseekers;
      notifyListeners();
    } catch (error) {
      Utils.logMessage('jobseeker list manager: $error');
    }
  }

  Future<void> lockAccount(LockedUser lockedUser) async {
    try {
      final result = await _jobseekerService.lockAccount(lockedUser);
      if (result != null) {
        _lockedJobseekersList.add(result);
        notifyListeners();
      }
    } catch (error) {
      Utils.logMessage('jobseeker list manager: $error');
    }
  }

  bool isLocked(String userId) {
    return _lockedJobseekersList.any((locked) => locked.userId == userId);
  }

  Future<void> unlockAccount(String userId) async {
    final result = await _jobseekerService.unlockAccount(userId);
    if (result) {
      _lockedJobseekersList.removeWhere((locked) => locked.userId == userId);
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String userId) async {
    final result = await _jobseekerService.deleteAccount(userId);
    if (result) {
      _jobseekersList.removeWhere((jobseeker) => jobseeker.id == userId);
      notifyListeners();
    }
  }

  void searchJobseeker(String searchText) {
    //Loại bỏ dấu tiếng việt để dễ dàng trong tìm kiếm
    String removedAccentSearchText = Utils.removeVietnameseAccent(searchText);
    _filteredJobseekersList = _filteredJobseekersList.where((jobseeker) {
      //Loại bỏ dấu tiếng Việt của thông tin Jobseeker trước
      String alteredJobseeker =
          Utils.removeVietnameseAccent(jobseeker.toString());
      return alteredJobseeker
          .toLowerCase()
          .contains(removedAccentSearchText.toLowerCase());
    }).toList();
    notifyListeners();
  }

  void resetSearch() {
    _filteredJobseekersList = _jobseekersList;
    Utils.logMessage('Reset search jobseekers');
    notifyListeners();
  }

  void sortJobseekers(int sortOption) {
    if (sortOption == 0) {
      _filteredJobseekersList.setAll(0, _jobseekersList);
      Utils.logMessage(_filteredJobseekersList.toString());
      Utils.logMessage('Base list: ${_jobseekersList.toString()}');
    } else if (sortOption == 1) {
      //Sắp xếp theo thứ tự tỉnh thành phố A - Z
      _filteredJobseekersList.sort((a, b) {
        return a.address.compareTo(b.address);
      });
      Utils.logMessage(_filteredJobseekersList.toString());
    } else if (sortOption == 2) {
      //Sắp xếp theo thứ tự bảng chữ cái A - Z
      _filteredJobseekersList.sort((a, b) {
        String lastWordA = a.firstName.split(' ').last;
        String lastWordB = b.firstName.split(' ').last;
        return lastWordA.compareTo(lastWordB);
      });
      Utils.logMessage(_filteredJobseekersList.toString());
    }
    notifyListeners();
  }
}
