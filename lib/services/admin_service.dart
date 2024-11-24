import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/account_status_data.dart';
import 'package:job_finder_app/models/application_stats_data.dart';
import 'package:job_finder_app/models/job_count_data.dart';
import 'package:job_finder_app/models/recruitment_area_data.dart';
import 'package:job_finder_app/models/user_registration_data.dart';
import 'package:job_finder_app/services/node_service.dart';

class AdminService extends NodeService {
  AdminService([super.authToken]);

  final headers = {'Content-Type': 'application/json; charset=UTF-8'};

  Future<List<UserRegistrationData>> getTotalUserRegistrationByRange(
      TimeRange timeRage) async {
    final query = switch (timeRage) {
      TimeRange.thisWeek => 'week',
      TimeRange.thisMonth => 'month',
      TimeRange.thisYear => 'year',
    };
    try {
      final response = await httpFetch(
        '$databaseUrl/api/admin/user-registration?period=$query',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      //Chuyển mỗi phần tử sang Map
      List<Map<String, dynamic>> responseMapList =
          List<Map<String, dynamic>>.from(response);
      //Chuyển đổi thành kiểu UserRegistrationData
      List<UserRegistrationData> userRegistrationData = responseMapList
          .map((userRegistrationMap) =>
              UserRegistrationData.fromJson(userRegistrationMap))
          .toList();
      return userRegistrationData;
    } catch (error) {
      Utils.logMessage(
          'Error in getTotalUserRegistrationInWeek service: $error');
      return [];
    }
  }

  //Hàm thống kê trạng thái khóa của mỗi nhóm người
  Future<AccountStatusData?> getAccountStatusData() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/admin/user-account-status',
        headers: headers,
        method: HttpMethod.get,
      ) as Map<String, dynamic>;
      final accountStatusList = AccountStatusData.fromJson(response);

      return accountStatusList;
    } catch (error) {
      Utils.logMessage('Error in getAccountStatusData: $error');
      return null;
    }
  }

  //Hàm thống kê số lượng công việc theo các mốc thời gian 7 ngày qua, 4 tuần qua, 5 tháng qua
  Future<List<JobCountData>> getJobpostingCountByRange(
      JobPostTimeRange timeRage) async {
    final query = switch (timeRage) {
      JobPostTimeRange.past7Days => "past7days",
      JobPostTimeRange.past4Weeks => "past4weeks",
      JobPostTimeRange.past5Month => "past5months",
    };
    try {
      final response = await httpFetch(
        '$databaseUrl/api/admin/jobposting-stats?period=$query',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      //Chuyển mỗi phần tử sang kiểu Map
      List<Map<String, dynamic>> responseMapList =
          List<Map<String, dynamic>>.from(response);
      //Chuyển mỗi phần tử sang kiểu JobCountData
      List<JobCountData> jobCountList = responseMapList
          .map((jobCountItem) => JobCountData.fromJson(jobCountItem))
          .toList();
      return jobCountList;
    } catch (error) {
      Utils.logMessage('Error in getJobpostingCountByRange: $error');
      return [];
    }
  }

  //Hàm thống kê trạng thái các hồ sơ theo mốc thời gian
  Future<List<ApplicationStatsData>> getApplicationStatsByRange(
      TimeRange timeRange) async {
    final query = switch (timeRange) {
      TimeRange.thisWeek => 'week',
      TimeRange.thisMonth => 'month',
      TimeRange.thisYear => 'year',
    };
    try {
      final response = await httpFetch(
        '$databaseUrl/api/admin/application-stats?period=$query',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;

      //Chuyển mỗi phần tử sang kiểu Map
      List<Map<String, dynamic>> responseMapList =
          List<Map<String, dynamic>>.from(response);
      //Chuyển mỗi phần tử sang kiểu ApplicationStatsData
      List<ApplicationStatsData> applicationStatsList = responseMapList
          .map((applicationStatsItem) =>
              ApplicationStatsData.fromJson(applicationStatsItem))
          .toList();
      return applicationStatsList;
    } catch (error) {
      Utils.logMessage('Error in getApplicationStatsByRange: $error');
      return [];
    }
  }

  Future<List<RecruitmentAreaData>> getRecruitmentAreaStats() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/admin/recruitment-area',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      //Chuyển mỗi phần tử sang kiểu Map
      final responseMapList = List<Map<String, dynamic>>.from(response);
      //Chuyển mỗi phần tử sang kiểu RecruitmentAreaData
      final areaStats = responseMapList
          .map((stats) => RecruitmentAreaData.fromJson(stats))
          .toList();
      return areaStats;
    } catch (error) {
      Utils.logMessage('Error in getRecruitmentAreaStats $error');
      return [];
    }
  }
}
