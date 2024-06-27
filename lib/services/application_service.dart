import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:job_finder_app/models/application_storage.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/node_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../models/jobseeker.dart';

class ApplicationService extends NodeService {
  ApplicationService([AuthToken? authToken]) : super(authToken);

  final headers = {'Content-Type': 'application/json; charset=UTF-8'};

  Future<String?> downloadFile(String url, String filename) async {
    try {
      //Yêu cầu quyền
      if (await _requestPermission()) {
        //? Tải vào thư mục Download public của điện thoại
        String path = '/storage/emulated/0/Download/';

        String fullPath = "$path/$filename";
        final response = await http.get(Uri.parse('$databaseUrl/$url'));
        if (response.statusCode == 200) {
          File file = File(fullPath);
          await file.writeAsBytes(response.bodyBytes);
          log('Download file success: $fullPath');
          return fullPath;
        } else {
          log('Error in application service: $response');
        }
        return null;
      }
    } catch (error) {
      log('Error in application service: $error');
      return null;
    }
  }

  Future<bool> _requestPermission() async {
    log('Request is Call');
    try {
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        log('Status la: $status');
        return status.isGranted;
      } else {
        return true;
      }
    } catch (error) {
      log('Error in application service: $error');
      return false;
    }
  }

  Future<List<ApplicationStorage>?> getAllPostApplicationList() async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
    String companyId = decodedToken['companyId'];
    log('CompanyId la: $companyId');
    try {
      final response = await httpFetch(
        '$databaseUrl/api/application/company/$companyId',
        method: HttpMethod.get,
        headers: headers,
      ) as List<dynamic>;
      //todo Chuyển đổi mỗi phần tử dynamic trong List<dynamic> thành Map<String, dynamic>
      List<Map<String, dynamic>> responseMapList =
          List<Map<String, dynamic>>.from(response);
      //todo chuyển đổi phần tử Map thành ApplicationStorage
      List<ApplicationStorage> applicationStorageList =
          responseMapList.map((e) => ApplicationStorage.fromJson(e)).toList();
      return applicationStorageList;
    } catch (error) {
      log('Error in application service - getAllPostApplicationList: $error');
      return null;
    }
  }

  Future<bool> applyApplication(
      String jobpostingId, String jobseekerId, String employerEmail) async {
    try {
      await httpFetch(
        '$databaseUrl/api/application/',
        method: HttpMethod.post,
        headers: headers,
        body: jsonEncode({
          "jobId": jobpostingId,
          "jobseekerId": jobseekerId,
          "employerEmail": employerEmail,
        }),
      );
      return true;
    } catch (error) {
      log('Error in application service: $error');
      return false;
    }
  }

  //?Hàm chấp nhận một hồ sơ cụ thể
  Future<bool> acceptApplication(
      String jobpostingId, String jobseekerId) async {
    try {
      await httpFetch(
        '$databaseUrl/api/application/jobposting/$jobpostingId',
        method: HttpMethod.post,
        headers: headers,
        body: jsonEncode({
          "jobseekerId": jobseekerId,
          "status": 1,
        }),
      );
      return true;
    } catch (error) {
      log('Error in application service: $error');
      return false;
    }
  }

  //?Hàm từ chối một hồ sơ cụ thể
  Future<bool> rejectApplication(
      String jobpostingId, String jobseekerId) async {
    try {
      await httpFetch(
        '$databaseUrl/api/application/jobposting/$jobpostingId',
        method: HttpMethod.post,
        headers: headers,
        body: jsonEncode({
          "jobseekerId": jobseekerId,
          "status": 2,
        }),
      );
      return true;
    } catch (error) {
      log('Error in application service: $error');
      return false;
    }
  }

  Future<Jobseeker?> fetchJobseekerById(String id) async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/jobseeker/$id',
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        method: HttpMethod.get,
      ) as Map<String, dynamic>;

      final jobseeker = Jobseeker.fromJson(response);

      return jobseeker;
    } catch (error) {
      log('job service - fetchJobseekerById: ${error}');
      return null;
    }
  }
}
