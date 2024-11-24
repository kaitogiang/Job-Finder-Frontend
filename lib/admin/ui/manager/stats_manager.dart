import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/sample.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/account_status_data.dart';
import 'package:job_finder_app/models/application_stats_data.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/job_count_data.dart';
import 'package:job_finder_app/models/recruitment_area_data.dart';
import 'package:job_finder_app/models/user_registration_data.dart';
import 'package:job_finder_app/services/admin_service.dart';

class StatsManager extends ChangeNotifier {
  //Danh sách các thống kê
  //Dữ liệu cho thống kế số lượng người đăng ký
  List<UserRegistrationData> _userStatsData = [];
  List<UserRegistrationData> _userStatsDataInWeek = []; //Tổng đăng ký tuần này
  List<UserRegistrationData> _userStatsDataInMonth =
      []; //Tổng đăng ký tháng này
  List<UserRegistrationData> _userStatsDataInYear = []; //Tổng đăng ký năm này
  //Dữ liệu thống kê cho số lượng công việc mới
  List<JobCountData> _jobStatsData = [];
  List<JobCountData> _jobStatsDataPast7Days = [];
  List<JobCountData> _jobStatsDataPast4Weeks = [];
  List<JobCountData> _jobStatsDataPast5Months = [];
  //Dữ liệu thống kê trạng thái tài khoản
  AccountStatusData? _accountStatusData;
  //Dữ liệu thống kê cho tổng số hồ sơ ứng tuyển
  List<ApplicationStatsData> _applicationStatsData = [];
  List<ApplicationStatsData> _applicationStatsDataInWeek = [];
  List<ApplicationStatsData> _applicationStatsDataInMonth = [];
  List<ApplicationStatsData> _applicationStatsDataInYear = [];
  //Dữ liệu thống kê những khu vực có ứng tuyển
  List<RecruitmentAreaData> _recruitmentAreaData = [];

  //Khởi tạo các dịch vụ, thêm dịch vụ của admin vào
  final AdminService _adminService;

  StatsManager([AuthToken? authToken])
      : _adminService = AdminService(authToken);

  set authToken(AuthToken? authToken) {
    //gán lại authToken cho các dịch vụ
    _adminService.authToken = authToken;
    notifyListeners();
  }

  //Các hàm getter
  /*Lấy danh sách dữ liệu thống kê của người dùng đăng ký
    bao gồm cả jobseeker và employer
  */
  List<UserRegistrationData> get userStatsData => _userStatsData;

  List<JobCountData> get jobStatsData => _jobStatsData;

  AccountStatusData get accountStatusData => _accountStatusData!;

  List<ApplicationStatsData> get applicationStatsData => _applicationStatsData;

  List<RecruitmentAreaData> get recruitmentAreaData => _recruitmentAreaData;

  //Lấy tổng số của mỗi số lượng người dùng theo mốc thời gian
  int get totalUserRegistrationInWeek {
    return _userStatsDataInWeek.fold(0, (previous, stats) {
      double total = stats.jobseekerCount + stats.employerCount;
      return previous + total.toInt();
    });
  }

  int get totalUserRegistrationInMonth {
    return _userStatsDataInMonth.fold(0, (previous, stats) {
      double total = stats.jobseekerCount + stats.employerCount;
      return previous + total.toInt();
    });
  }

  int get totalUserRegistrationInYear {
    return _userStatsDataInYear.fold(0, (previous, stats) {
      double total = stats.jobseekerCount + stats.employerCount;
      return previous + total.toInt();
    });
  }

  //Tính trung bình của số người dăng ký theo mốc thời gian
  int get averageUserRegistrationInWeek {
    double avg = totalUserRegistrationInWeek / 7;
    return avg.toInt();
  }

  int get averageUserRegistrationInMonth {
    double avg = totalUserRegistrationInMonth / 4;
    return avg.toInt();
  }

  int get averageUserRegistrationInYear {
    double avg = totalUserRegistrationInYear / 12;
    return avg.toInt();
  }

  //Tính tổng số lượng công việc mới theo từng mốc thời gian
  int getTotalJobpostingCountByRange(JobPostTimeRange timeRange) {
    if (timeRange == JobPostTimeRange.past7Days) {
      return _jobStatsDataPast7Days.fold(0, (previous, jobCountItem) {
        return previous + jobCountItem.jobCount.toInt();
      });
    } else if (timeRange == JobPostTimeRange.past4Weeks) {
      return _jobStatsDataPast4Weeks.fold(0, (previous, jobCountItem) {
        return previous + jobCountItem.jobCount.toInt();
      });
    } else {
      return _jobStatsDataPast5Months.fold(0, (previous, jobCountItem) {
        return previous + jobCountItem.jobCount.toInt();
      });
    }
  }

  Future<void> fetchAllStatsData() async {
    try {
      //Số người đăng ký
      _userStatsDataInWeek = await _adminService
          .getTotalUserRegistrationByRange(TimeRange.thisWeek);
      _userStatsDataInMonth = await _adminService
          .getTotalUserRegistrationByRange(TimeRange.thisMonth);
      _userStatsDataInYear = await _adminService
          .getTotalUserRegistrationByRange(TimeRange.thisYear);
      //Trạng thái tài khoản
      _accountStatusData = await _adminService.getAccountStatusData();
      //Số lượng công việc mới được đăng tải
      _jobStatsDataPast7Days = await _adminService
          .getJobpostingCountByRange(JobPostTimeRange.past7Days);
      _jobStatsDataPast4Weeks = await _adminService
          .getJobpostingCountByRange(JobPostTimeRange.past4Weeks);
      _jobStatsDataPast5Months = await _adminService
          .getJobpostingCountByRange(JobPostTimeRange.past5Month);
      //Trạng thái các đơn ứng tuyển
      _applicationStatsDataInWeek =
          await _adminService.getApplicationStatsByRange(TimeRange.thisWeek);
      _applicationStatsDataInMonth =
          await _adminService.getApplicationStatsByRange(TimeRange.thisMonth);
      _applicationStatsDataInYear =
          await _adminService.getApplicationStatsByRange(TimeRange.thisYear);
      //Các khu vực có ứng tuyển
      _recruitmentAreaData = await _adminService.getRecruitmentAreaStats();
      //Gán lại dữ liệu để hiển thị trên màn hình
      _userStatsData = [..._userStatsDataInWeek];
      _jobStatsData = [..._jobStatsDataPast7Days];
      _applicationStatsData = [..._applicationStatsDataInWeek];
      notifyListeners();
    } catch (error) {
      Utils.logMessage('Error in fetchAllStatsData manager: $error');
    }
  }

  //Các hàm setter
  //Hàm gán lại userStatsData dựa vào mốc thời gian đã chọn
  void setUserStatsDataByTimeRange(TimeRange timeRange) {
    switch (timeRange) {
      case TimeRange.thisWeek:
        _userStatsData = _userStatsDataInWeek;
        break;
      case TimeRange.thisMonth:
        _userStatsData = _userStatsDataInMonth;
        break;
      case TimeRange.thisYear:
        _userStatsData = _userStatsDataInYear;
        break;
    }
    notifyListeners();
  }

  //Hàm gán lại jobStatsData dựa vào mốc thời gian đã chọn
  void setJobStatsDataByTimeRange(JobPostTimeRange timeRage) {
    switch (timeRage) {
      case JobPostTimeRange.past7Days:
        _jobStatsData = [..._jobStatsDataPast7Days];
        break;
      case JobPostTimeRange.past4Weeks:
        _jobStatsData = [..._jobStatsDataPast4Weeks];
        break;
      case JobPostTimeRange.past5Month:
        _jobStatsData = [..._jobStatsDataPast5Months];
        break;
    }
    notifyListeners();
  }

  //Hàm gán lại applicationStatsData dựa vào mốc thời gian đã chọn
  void setApplicationStatsDataByTimeRange(TimeRange timeRange) {
    switch (timeRange) {
      case TimeRange.thisWeek:
        _applicationStatsData = [..._applicationStatsDataInWeek];
        break;
      case TimeRange.thisMonth:
        _applicationStatsData = [..._applicationStatsDataInMonth];
        break;
      case TimeRange.thisYear:
        _applicationStatsData = [..._applicationStatsDataInYear];
        break;
    }
    notifyListeners();
  }
}
