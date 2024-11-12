import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/sample.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/application_stats_data.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/models/job_count_data.dart';
import 'package:job_finder_app/models/user_registration_data.dart';

class StatsManager extends ChangeNotifier {
  //Danh sách các thống kê
  //Dữ liệu cho thống kế số lượng người đăng ký
  List<UserRegistrationData> _userStatsData = [];
  //Dữ liệu thống kê cho số lượng công việc mới
  List<JobCountData> _jobStatsData = [];
  //Dữ liệu thống kê cho tổng số hồ sơ ứng tuyển
  List<ApplicationStatsData> _applicationStatsData = [];

  //TODO Khởi tạo các dịch vụ, thêm dịch vụ của admin vào
  StatsManager([AuthToken? authToken]);

  set authToken(AuthToken? authToken) {
    //TODO gán lại authToken cho các dịch vụ
    notifyListeners();
  }

  //Các hàm getter
  /*Lấy danh sách dữ liệu thống kê của người dùng đăng ký
    bao gồm cả jobseeker và employer
  */
  List<UserRegistrationData> get userStatsData => _userStatsData;

  List<JobCountData> get jobStatsData => _jobStatsData;

  List<ApplicationStatsData> get applicationStatsData => _applicationStatsData;

  Future<void> fetchAllStatsData() async {
    try {
      //TODO nạp dữ liệu từ dịch vụ vào
      await Future.delayed(
        Duration(seconds: 2),
        () {
          _userStatsData = dailyData;
          _jobStatsData = jobDailyData;
          _applicationStatsData = weeklyApplicationStats;
        },
      );
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
        _userStatsData = dailyData;
        break;
      case TimeRange.thisMonth:
        _userStatsData = weeklyData;
        break;
      case TimeRange.thisYear:
        _userStatsData = monthlyData;
        break;
    }
    notifyListeners();
  }

  //Hàm gán lại jobStatsData dựa vào mốc thời gian đã chọn
  void setJobStatsDataByTimeRange(JobPostTimeRange timeRage) {
    switch (timeRage) {
      case JobPostTimeRange.past7Days:
        _jobStatsData = jobDailyData;
        break;
      case JobPostTimeRange.past4Weeks:
        _jobStatsData = jobWeeklyData;
        break;
      case JobPostTimeRange.past5Month:
        _jobStatsData = jobMonthlyData;
        break;
    }
    notifyListeners();
  }

  //Hàm gán lại applicationStatsData dựa vào mốc thời gian đã chọn
  void setApplicationStatsDataByTimeRange(TimeRange timeRange) {
    switch (timeRange) {
      case TimeRange.thisWeek:
        _applicationStatsData = weeklyApplicationStats;
        break;
      case TimeRange.thisMonth:
        _applicationStatsData = monthlyApplicationStats;
        break;
      case TimeRange.thisYear:
        _applicationStatsData = yearlyApplicationStats;
        break;
    }
    notifyListeners();
  }
}
