import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/utils/vietname_provinces.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/employer.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/models/locked_users.dart';
import 'package:job_finder_app/services/employer_service.dart';
import 'package:job_finder_app/services/jobseeker_service.dart';

class EmployerListManager extends ChangeNotifier {
  // final List<Map<String, dynamic>> _jobseekersList = jobseekers;
  List<Employer> _employersList = [];
  List<Employer> _recentEmployersList = [];
  List<LockedUser> _lockedEmployersList = [];
  List<Employer> _filteredEmployersList = [];

  //khởi tạo dịch vụ
  final EmployerService _employerService;

  EmployerListManager([AuthToken? authToken])
      : _employerService = EmployerService(authToken);

  set authToken(AuthToken? authToken) {
    _employerService.authToken = authToken;
    Utils.logMessage('Cập nhật authToken cho EmployerService');
    notifyListeners();
  }

  List<Employer> getEmployers() => _employersList;

  List<Employer> get filteredEmployers => _filteredEmployersList;

  List<Employer> get employerList => _employersList;

  List<Employer> get recentEmployersList => _recentEmployersList;

  List<Employer> get lockedEmployersList => _employersList
      .where((e) => _lockedEmployersList.any((locked) => locked.userId == e.id))
      .toList();

  set employerList(List<Employer> list) {
    _employersList = list;
  }

  //Hàm lấy số lượng phần tử trong danh sách
  int get getEmployersCount => _employersList.length;

  int get getFilteredEmployersCount => _filteredEmployersList.length;
  int get getRecentEmployersCount => _recentEmployersList.length;

  int get getLockedEmployersCount => _lockedEmployersList.length;

  int get activeEmployersCount => getEmployersCount - getLockedEmployersCount;

  //Hàm lấy danh sách ứng viên theo nhóm 5 người, pageNumber là số thứ tự nhóm đó bắt đầu từ 1
  //Ví dụ: pageNumber = 1 -> lấy nhóm 1, pageNumber = 2 -> lấy nhóm 2, ...
  //PageNumber - 1 tương đương với index bắt đầu của nhóm 5 người.
  List<Employer> getEmployerByPage(
      int pageNumber, int groupSize, List<Employer> list) {
    int startIndex = (pageNumber - 1) * groupSize;
    int endIndex = (startIndex + groupSize) > list.length
        ? list.length
        : startIndex + groupSize;
    return list.sublist(startIndex, endIndex);
  }

  //Hàm lấy số lượng nhóm có thể hiển thị trong number pagination,
  //hàm này tự động làm tròn lên số lớn hơn nếu có phần dư
  //Ví dụ 0.1 -> 1, 0.5 -> 1, 0.9 -> 1
  int getTotalGroupCount(int groupSize, List<Employer> list) {
    return (list.length / groupSize).ceil();
  }

  //hàm nạp tất cả các jobseeker
  Future<void> getAllJobseekers() async {
    try {
      //TODO: Lấy dữ liệu từ server

      // List<Employer> employers = await _employerService.getAllEmployers();
      // List<Employer> recentEmployers =
      //     await _employerService.getAllRecentEmployers();
      // List<LockedUser> lockedEmployers =
      //     await _employerService.getAllLockedEmployers();
      // employerList = employers;
      // _filteredEmployersList.addAll(employers);
      // _recentEmployersList = recentEmployers;
      // _lockedEmployersList = lockedEmployers;
      notifyListeners();
    } catch (error) {
      Utils.logMessage('jobseeker list manager: $error');
    }
  }

  Future<void> lockAccount(LockedUser lockedUser) async {
    try {
      //TODO: Lấy dữ liệu từ server

      // final result = await _jobseekerService.lockAccount(lockedUser);
      // if (result != null) {
      //   _lockedJobseekersList.add(result);
      //   notifyListeners();
      // }
    } catch (error) {
      Utils.logMessage('jobseeker list manager: $error');
    }
  }

  bool isLocked(String userId) {
    return _lockedEmployersList.any((locked) => locked.userId == userId);
  }

  Future<void> unlockAccount(String userId) async {
    //TODO: Lấy dữ liệu từ server

    // final result = await _employerService.unlockAccount(userId);
    // if (result) {
    //   _lockedEmployersList.removeWhere((locked) => locked.userId == userId);
    // notifyListeners();
    // }
  }

  Future<void> deleteAccount(String userId) async {
    //TODO: Lấy dữ liệu từ server

    // final result = await _employerService.deleteAccount(userId);
    // if (result) {
    //   _employersList.removeWhere((employer) => employer.id == userId);
    //   notifyListeners();
    // }
  }

  void searchJobseeker(String searchText) {
    //Loại bỏ dấu tiếng việt để dễ dàng trong tìm kiếm
    String removedAccentSearchText = Utils.removeVietnameseAccent(searchText);
    // _filteredEmployersList = _filteredEmployersList.where((employer) {
    //   //Loại bỏ dấu tiếng Việt của thông tin Jobseeker trước
    //   String alteredEmployer =
    //       Utils.removeVietnameseAccent(employer.toString());
    //   return alteredEmployer
    //       .toLowerCase()
    //       .contains(removedAccentSearchText.toLowerCase());
    // }).toList();
  }

  void resetSearch() {
    // _filteredEmployersList = _employersList;
    // Utils.logMessage('Reset search employers');
    // notifyListeners();
  }

  void sortJobseekers(int sortOption) {
    // if (sortOption == 0) {
    //   _filteredJobseekersList.setAll(0, _jobseekersList);
    //   Utils.logMessage(_filteredJobseekersList.toString());
    //   Utils.logMessage('Base list: ${_jobseekersList.toString()}');
    // } else if (sortOption == 1) {
    //   //Sắp xếp theo thứ tự tỉnh thành phố A - Z
    //   _filteredJobseekersList.sort((a, b) {
    //     return a.address.compareTo(b.address);
    //   });
    //   Utils.logMessage(_filteredJobseekersList.toString());
    // } else if (sortOption == 2) {
    //   //Sắp xếp theo thứ tự bảng chữ cái A - Z
    //   _filteredJobseekersList.sort((a, b) {
    //     String lastWordA = a.firstName.split(' ').last;
    //     String lastWordB = b.firstName.split(' ').last;
    //     return lastWordA.compareTo(lastWordB);
    //   });
    //   Utils.logMessage(_filteredJobseekersList.toString());
    // }
    // notifyListeners();
  }
}
