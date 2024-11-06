import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:universal_html/html.dart' as html;

import 'package:job_finder_app/models/application_storage.dart';
import 'package:job_finder_app/services/node_service.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../models/employer.dart';
import '../models/jobseeker.dart';

class ApplicationService extends NodeService {
  ApplicationService([super.authToken]);

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
      return null;
    } catch (error) {
      log('Error in application service: $error');
      return null;
    }
  }

  Future<void> downloadFileFromWeb(String url, String filename) async {
    final link = '$databaseUrl/$url';
    try {
      final response = await http.get(Uri.parse(link));
      if (response.statusCode == 200) {
        //Blob một một đối tượng đại diện cho dữ liệu thô được lưu trữ dưới dạng
        //mảng các byte. Blob có thể được dùng để tạo ra một file có thể tải được
        //Lệnh này tạo một đối tượng Blob từ mảng byte của response.bodyBytes
        final blob = html.Blob([response.bodyBytes]);
        //Tạo một url tạm thời mà cho phép browser có thể truy cập được
        //đối tượng blob. URL này chỉ tồn tại khi trang còn mở
        final objectUrl = html.Url.createObjectUrlFromBlob(blob);

        //Tạo một thẻ <a> trong html với thuộc tính href là objectUrl, có nghĩa
        //là tạo liên kết đến url tạm thời của file blob. Đồng thời, nó
        //đặt thuộc tính download của thẻ <a> là filename, filename là tên của
        //file sẽ được tải về. Thẻ <a> trong html sẽ có dạng như sau:
        //<a href="objectUrl" download="filename"></a>
        //Thêm nữa, nó kích hoạt sự kiện tải xuống tự động khi gọi click(), giúp
        //tự động tải về mà không cần người dùng click vào liên kết
        html.AnchorElement(href: objectUrl)
          ..setAttribute("download", filename)
          ..click();
        //Giải phóng objectUrl để tránh rò rỉ bộ nhớ
        html.Url.revokeObjectUrl(objectUrl);
      } else {
        Utils.logMessage(
            'Error in application service - downloadFileFromWeb: $response');
      }
    } catch (error) {
      Utils.logMessage(
          'Error in application service - downloadFileFromWeb: $error');
    }
  }

  Future<bool> _requestPermission() async {
    log('Request is Call');
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
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
    log('CompanyId: $companyId');
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
      String jobpostingId, String employerEmail) async {
    try {
      await httpFetch(
        '$databaseUrl/api/application/',
        method: HttpMethod.post,
        headers: headers,
        body: jsonEncode({
          "jobId": jobpostingId,
          "jobseekerId": userId,
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
      log('job service - fetchJobseekerById: $error');
      return null;
    }
  }

  Future<List<ApplicationStorage>?> fetchJobseekerApplication() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/application/jobseeker/$userId',
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        method: HttpMethod.get,
      ) as List<dynamic>;
      List<Map<String, dynamic>> responseMap =
          List<Map<String, dynamic>>.from(response);

      List<ApplicationStorage> applicationStorageList =
          responseMap.map((e) => ApplicationStorage.fromJson(e)).toList();
      return applicationStorageList;
    } catch (error) {
      log('job service - fetchJobseekerApplication: $error');
      return null;
    }
  }

  Future<Employer?> getEmployerByCompanyId(String companyId) async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/application/company/$companyId/employer',
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        method: HttpMethod.get,
      ) as Map<String, dynamic>;
      final employer = Employer.fromJson(response);
      return employer;
    } catch (error) {
      log('job service - getEmployerByCompanyId: $error');
      return null;
    }
  }
}
