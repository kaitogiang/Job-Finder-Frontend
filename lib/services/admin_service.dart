import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/account_status_data.dart';
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
}
