import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/application.dart';
import 'package:job_finder_app/models/application_storage.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/application_service.dart';

class ApplicationListManager with ChangeNotifier {
  List<ApplicationStorage> _applications = [];
  List<ApplicationStorage> _filteredApplications = [];

  //Định nghĩa các dịch vụ sẽ sử dụng
  final ApplicationService _applicationService;

  //Hàm xây dựng lớp
  ApplicationListManager([AuthToken? authToken])
      : _applicationService = ApplicationService(authToken);

  //Các hàm setter
  set authToken(AuthToken? authToken) {
    _applicationService.authToken = authToken;
  }

  //Các hàm getter các list
  List<ApplicationStorage> get applications => _applications;
  List<ApplicationStorage> get filteredApplication => _filteredApplications;

  //Các hàm getter lấy dữ liệu
  //Hàm trả về tất cả các hồ sơ đã ứng tuyển, ở mọi bài đăng
  int get totalJobseekerApplication {
    return _applications.fold<int>(0, (previous, storage) {
      return previous + storage.applications.length;
    });
  }

  //Lấy số lượng application trong vòng 1 tuần
  int get applicationCountWithinOneWeek {
    //Lọc những storage nào
    return _applications.fold<int>(0, (previous, storage) {
      //Kiểm tra xem mỗi danh sách application trong mỗi ApplicationStorage,
      //thì application nào được gửi trong vòng 1 tuần.
      //Kiểm tra mảng application trong mỗi ApplicationStorage
      //**Lấy số lượng application gửi trong vòng 1 tuần của mỗi Storage
      int oneWeekJobpostingApplication = storage.applications
          .where((application) {
            //Chuyển đổi ngày giờ trong application sang Datime để so sánh với hôm nay
            DateTime now = DateTime.now();
            DateTime submittedAt = DateTime.parse(application.submittedAt);
            final days = now.difference(submittedAt).inDays;
            return days <= 7;
          })
          .toList()
          .length;
      return previous + oneWeekJobpostingApplication;
    });
  }

  //Hàm lấy số lượng những hồ sơ đang xử lý
  int get totalProgressingApplications {
    return _applications.fold<int>(0, (previous, storage) {
      //Đếm hồ sơ nào đang được tiến hành trong mỗi storage
      final progressingApplicationCount = storage.applications
          .where((application) => application.status == 0)
          .toList()
          .length;
      return previous + progressingApplicationCount;
    });
  }

  //Hàm lấy số lượng những hồ sơ được chấp nhận
  int get totalApprovedApplications {
    return _applications.fold<int>(0, (previous, storage) {
      //Đếm hồ sơ nào đang được tiến hành trong mỗi storage
      final provedApplicationCount = storage.applications
          .where((application) => application.status == 1)
          .toList()
          .length;
      return previous + provedApplicationCount;
    });
  }

  //Hàm lấy số lượng những hồ sơ bị từ chối
  int get totalRejectedApplications {
    return _applications.fold<int>(0, (previous, storage) {
      //Đếm hồ sơ nào đang được tiến hành trong mỗi storage
      final rejectedApplicationCount = storage.applications
          .where((application) => application.status == 2)
          .toList()
          .length;
      return previous + rejectedApplicationCount;
    });
  }

  //Hàm lấy danh sách ứng viên theo nhóm 5 người, pageNumber là số thứ tự nhóm đó bắt đầu từ 1
  //Ví dụ: pageNumber = 1 -> lấy nhóm 1, pageNumber = 2 -> lấy nhóm 2, ...
  //PageNumber - 1 tương đương với index bắt đầu của nhóm 5 người.
  List<ApplicationStorage> getJobpostingByPage(
      int pageNumber, int groupSize, List<ApplicationStorage> list) {
    int startIndex = (pageNumber - 1) * groupSize;
    int endIndex = (startIndex + groupSize) > list.length
        ? list.length
        : startIndex + groupSize;
    return list.sublist(startIndex, endIndex);
  }

  //Hàm lấy số lượng nhóm có thể hiển thị trong number pagination,
  //hàm này tự động làm tròn lên số lớn hơn nếu có phần dư
  //Ví dụ 0.1 -> 1, 0.5 -> 1, 0.9 -> 1
  int getTotalGroupCount(int groupSize, List<ApplicationStorage> list) {
    return (list.length / groupSize).ceil();
  }

  //Hàm nạp dữ liệu từ server
  Future<void> fetchJobpostings() async {
    try {
      _applications = await _applicationService.fetchAllApplicatons();
      _filteredApplications = [..._applications];
    } catch (error) {
      Utils.logMessage(
          'Error in FetchAllJobposting in JobpostingListManager: $error');
    }
  }

  //Hàm lấy thông tin của một ApplicationStorage
  Future<ApplicationStorage?> getApplicationStorageById(String id) async {
    try {
      return _applicationService.getApplicationStorageById(id);
    } catch (error) {
      Utils.logMessage('Error in getApplicationStorage manager: $error');
      return null;
    }
  }

  //Hàm mở CV trong một tab mới trên web
  Future<void> viewJobseekerCV(String url) async {
    try {
      await _applicationService.openCVInNewTab(url);
    } catch (error) {
      Utils.logMessage('Error in viewJobseekerCV: $error');
    }
  }

  //Hàm tải xuống CV của một ứng viên
  Future<void> downloadJobseekerCV(String url, String filename) async {
    try {
      await _applicationService.downloadFileFromWeb(url, filename);
    } catch (error) {
      Utils.logMessage('Error in downloadJobseekerCV: $error');
    }
  }

  //Hàm tìm kiếm một application
  void searchApplicationJobposting(String searchText) {
    final formattedSearchText =
        Utils.removeVietnameseAccent(searchText).toLowerCase();
    final filteredApplications = _applications.where((application) {
      final applicationString = application.toString().toLowerCase();
      return applicationString.contains(formattedSearchText);
    }).toList();
    _filteredApplications = [...filteredApplications];
    notifyListeners();
  }

  //Hàm reset lại search
  void resetSearch() {
    _filteredApplications = [..._applications];
    notifyListeners();
  }
}
