import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/company.dart';
import 'package:job_finder_app/models/employer.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/models/locked_users.dart';
import 'package:job_finder_app/services/company_service.dart';
import 'package:job_finder_app/services/employer_service.dart';
import 'package:job_finder_app/services/jobposting_service.dart';

class EmployerListManager extends ChangeNotifier {
  // final List<Map<String, dynamic>> _jobseekersList = jobseekers;
  List<Employer> _employersList = [];
  List<Company> _companiesList = [];
  List<Employer> _recentEmployersList = [];
  List<LockedUser> _lockedEmployersList = [];
  List<Employer> _filteredEmployersList = [];
  List<Company> _filteredCompaniesList = [];

  //khởi tạo dịch vụ
  final EmployerService _employerService;
  final CompanyService _companyService;
  final JobpostingService _jobpostingService;

  EmployerListManager([AuthToken? authToken])
      : _employerService = EmployerService(authToken),
        _companyService = CompanyService(authToken),
        _jobpostingService = JobpostingService();

  set authToken(AuthToken? authToken) {
    _employerService.authToken = authToken;
    _companyService.authToken = authToken;
    _jobpostingService.authToken = authToken;
    Utils.logMessage('Cập nhật authToken cho EmployerService');
    notifyListeners();
  }

  List<Employer> getEmployers() => _employersList;

  List<Company> get companies => _companiesList;

  List<Company> get filteredCompanies => _filteredCompaniesList;

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

  List<Company> getCompanyByPage(
      int pageNumber, int groupSize, List<Company> list) {
    int startIndex = (pageNumber - 1) * groupSize;
    int endIndex = (startIndex + groupSize) > list.length
        ? list.length
        : startIndex + groupSize;
    return list.sublist(startIndex, endIndex);
  }

  //Hàm lấy số lượng nhóm có thể hiển thị trong number pagination,
  //hàm này tự động làm tròn lên số lớn hơn nếu có phần dư
  //Ví dụ 0.1 -> 1, 0.5 -> 1, 0.9 -> 1
  int getTotalAccountGroupCount(int groupSize, List<Employer> list) {
    return (list.length / groupSize).ceil();
  }

  int getTotalCompanyGroupCount(int groupSize, List<Company> list) {
    return (list.length / groupSize).ceil();
  }

  //Hàm trả về tên của công ty dựa vào companyId
  String getCompanyName(String companyId) {
    return _companiesList
        .firstWhere((company) => company.id == companyId)
        .companyName;
  }

  //hàm nạp tất cả các employer
  Future<void> getAllEmployers() async {
    try {
      List<Employer> employers = await _employerService.getAllEmployers();
      List<Employer> recentEmployers =
          await _employerService.getAllRecentEmployers();
      List<Company> companies = await _companyService.fetchAllCompanies();
      List<LockedUser> lockedEmployers =
          await _employerService.getAllLockedEmployers();
      employerList = employers;
      _filteredEmployersList = [...employers];
      _recentEmployersList = recentEmployers;
      _lockedEmployersList = lockedEmployers;
      _companiesList = companies;
      _filteredCompaniesList = [...companies];
      notifyListeners();
    } catch (error) {
      Utils.logMessage('jobseeker list manager: $error');
    }
  }

  Future<void> lockAccount(LockedUser lockedUser) async {
    try {
      final result = await _employerService.lockAccount(lockedUser);
      Utils.logMessage('result: $result');
      if (result != null) {
        Utils.logMessage('Thêm vào lockedEmployersList');
        _lockedEmployersList.add(result);
        notifyListeners();
      }
    } catch (error) {
      Utils.logMessage('jobseeker list manager: $error');
    }
  }

  bool isLocked(String userId) {
    return _lockedEmployersList.any((locked) => locked.userId == userId);
  }

  Future<void> unlockAccount(String userId) async {
    final result = await _employerService.unlockAccount(userId);
    if (result) {
      _lockedEmployersList.removeWhere((locked) => locked.userId == userId);
      notifyListeners();
    }
  }

  void searchCompany(String searchText) {
    //Loại bỏ dấu tiếng việt để dễ dàng trong tìm kiếm
    String removedAccentSearchText = Utils.removeVietnameseAccent(searchText);
    _filteredCompaniesList = _filteredCompaniesList.where((company) {
      //Loại bỏ dấu tiếng Việt của thông tin Jobseeker trước
      String alteredCompany = Utils.removeVietnameseAccent(company.toString());
      return alteredCompany
          .toLowerCase()
          .contains(removedAccentSearchText.toLowerCase());
    }).toList();
  }

  //Hàm reset danh sách tìm kiếm dựa vào kiểu sắp xếp hiện tại
  void resetCompanySearch(int currentSortOption) {
    //Vì bạn đầu khi người dùng search thì danh sách _filteredCompaniesList đã lọc và xóa bớt phần tử
    //Nên nếu chị gọi hàm sortCompany thì nó chỉ sắp xếp lại danh sách hiện có, tức là danh sách
    //kết quả của việc tìm kiếm nên số lượng phần tử không đúng. Do đó, ta cần phải nạp lại
    //danh sách ban đầu cho _filteredCompaniesList và sau đó sắp xếp
    _filteredCompaniesList = [..._companiesList];
    sortCompany(currentSortOption);

    Utils.logMessage('Reset search companies');
  }

  //Hàm tìm kiếm thông tin tài khoản hiện tại
  void searchAccount(String searchText) {
    String removedAccentSearchText = Utils.removeVietnameseAccent(searchText);
    //Lấy tên công ty và ghép vào chuỗi tìm kiếm
    _filteredEmployersList = _filteredEmployersList.where((employer) {
      String companyName = getCompanyName(employer.companyId);
      String alteredEmployer =
          Utils.removeVietnameseAccent('${employer.toString()} $companyName');
      return alteredEmployer
          .toLowerCase()
          .contains(removedAccentSearchText.toLowerCase());
    }).toList();
  }

  //Hàm reset danh sách tìm kiếm dựa vào kiểu sắp xếp hiện tại
  void resetAccountSearch(int currentSortOption) {
    _filteredEmployersList = [..._employersList];
    sortAccount(currentSortOption);
  }

  //Hàm sắp xếp danh sách công ty
  void sortCompany(int sortOption) {
    if (sortOption == 0) {
      _filteredCompaniesList = [..._companiesList];
    } else if (sortOption == 1) {
      //Sắp xếp theo thứ tự tên công ty
      _filteredCompaniesList.sort((a, b) {
        return a.companyName.compareTo(b.companyName);
      });
    } else if (sortOption == 2) {
      //Sắp xếp theo thứ tự theo Email
      _filteredCompaniesList.sort((a, b) {
        String emailA = a.companyEmail;
        String emailB = b.companyEmail;
        return emailA.compareTo(emailB);
      });
    } else if (sortOption == 3) {
      //Sắp xếp theo thứ tự theo số điện thoại
      _filteredCompaniesList.sort((a, b) {
        String phoneNumberA = a.companyPhone;
        String phoneNumberB = b.companyPhone;
        return phoneNumberA.compareTo(phoneNumberB);
      });
    }
    notifyListeners();
  }

  //Hàm sắp xếp danh sách các tài khoản
  void sortAccount(int sortOption) {
    //Sắp xếp theo mặc định
    if (sortOption == 0) {
      _filteredEmployersList = [..._employersList];
    } else if (sortOption == 1) {
      //Sắp xếp theo tên người dùng
      _filteredEmployersList.sort((a, b) {
        String fullNameA = '${a.firstName} ${a.lastName}';
        String fullNameB = '${b.firstName} ${b.lastName}';
        return fullNameA.compareTo(fullNameB);
      });
    } else if (sortOption == 2) {
      //Sắp xếp theo email
      _filteredEmployersList.sort((a, b) {
        String emailA = a.email;
        String emailB = b.email;
        return emailA.compareTo(emailB);
      });
    } else if (sortOption == 3) {
      //Sắp xếp theo số điện thoại
      _filteredEmployersList.sort((a, b) {
        String phoneNumberA = a.phone;
        String phoneNumberB = b.phone;
        return phoneNumberA.compareTo(phoneNumberB);
      });
    }
    notifyListeners();
  }

  //Hàm lấy thông tin công ty dựa vào companyId
  Future<Company?> getCompanyById(String companyId) async {
    try {
      return await _companyService.getCompanyById(companyId);
    } catch (error) {
      Utils.logMessage('employer list manager: $error');
      return null;
    }
  }

  //Hàm lấy danh sách các bài tuyển dụng của một công ty nhất định
  Future<List<Jobposting>?> getCompanyJobpostings(String companyId) async {
    try {
      return await _jobpostingService.getCompanyJobposting(companyId);
    } catch (error) {
      Utils.logMessage('employer list manager: $error');
      return null;
    }
  }

  //Hàm kiểm tra xem tài khoản có bị khóa không
  Future<bool> checkLockedAccount(String userId) async {
    try {
      return await _employerService.checkLockedAccount(userId);
    } catch (error) {
      Utils.logMessage(
          'employer list manager: $error in checkLockedAccount method');
      return false;
    }
  }

  //Hàm truy xuất thông tin tài khoản của một Employer
  Future<Employer?> getEmployerById(String userId) async {
    try {
      return await _employerService.getEmployerById(userId);
    } catch (error) {
      Utils.logMessage(
          'employer list manager: $error in getEmployerById method');
      return null;
    }
  }

  //Hàm lấy thông tin một company dựa vào employerId
  Future<Company?> getCompanyByEmployerId(String employerId) async {
    try {
      final result = await _employerService.getCompanyByEmployerId(employerId);
      return result;
    } catch (error) {
      Utils.logMessage(
          'employer list manager: $error in getCompanyByEmployerId method');
      return null;
    }
  }
}
