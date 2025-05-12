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
      // Request permission
      if (await _requestPermission()) {
        //? Download to the public Download folder of the phone
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
        // Blob is an object representing raw data stored as an array of bytes. 
        // Blob can be used to create a downloadable file
        // This command creates a Blob object from the byte array of response.bodyBytes
        final blob = html.Blob([response.bodyBytes]);
        // Create a temporary url that allows the browser to access
        // the blob object. This URL only exists while the page is open
        final objectUrl = html.Url.createObjectUrlFromBlob(blob);

        // Create an <a> tag in html with the href attribute is objectUrl, meaning
        // create a link to the temporary url of the blob file. At the same time, it
        // sets the download attribute of the <a> tag to filename, filename is the name of
        // the file to be downloaded. The <a> tag in html will look like this:
        //<a href="objectUrl" download="filename"></a>
        // Furthermore, it triggers the automatic download event when calling click(), helping
        // to automatically download without the user clicking on the link
        html.AnchorElement(href: objectUrl)
          ..setAttribute("download", filename)
          ..click();
        // Release objectUrl to avoid memory leak
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

  // Function to view CV information in a new tab
  Future<void> openCVInNewTab(String url) async {
    final link = '$databaseUrl/$url';
    try {
      final response = await http.get(Uri.parse(link));
      if (response.statusCode == 200) {
        final blob = html.Blob(
            [response.bodyBytes], 'application/pdf'); // Ensure blob is a PDF file
        final objectUrl = html.Url.createObjectUrlFromBlob(blob);

        // Set target="_blank" to open cv in a new tab instead of downloading
        html.AnchorElement(href: objectUrl)
          ..setAttribute("target", "_blank")
          ..click();

        // Release objectUrl to avoid memory leak
        html.Url.revokeObjectUrl(objectUrl);
      } else {
        Utils.logMessage('Error in onpenCVInNewTab service');
      }
    } catch (error) {
      Utils.logMessage('Error in openCVInNewTab service: $error');
    }
  }

  Future<bool> _requestPermission() async {
    log('Request is Call');
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        log('Status is: $status');
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
    log('CompanyId is: $companyId');
    try {
      final response = await httpFetch(
        '$databaseUrl/api/application/company/$companyId',
        method: HttpMethod.get,
        headers: headers,
      ) as List<dynamic>;
      //todo Convert each dynamic element in List<dynamic> to Map<String, dynamic>
      List<Map<String, dynamic>> responseMapList =
          List<Map<String, dynamic>>.from(response);
      //todo convert Map element to ApplicationStorage
      List<ApplicationStorage> applicationStorageList =
          responseMapList.map((e) => ApplicationStorage.fromJson(e)).toList();
      return applicationStorageList;
    } catch (error) {
      log('Error in application service - getAllPostApplicationList: $error');
      return null;
    }
  }

  Future<bool> applyApplication(
      String jobpostingId, String employerEmail, String resumeLink) async {
    try {
      await httpFetch(
        '$databaseUrl/api/application/',
        method: HttpMethod.post,
        headers: headers,
        body: jsonEncode({
          "jobId": jobpostingId,
          "jobseekerId": userId,
          "employerEmail": employerEmail,
          "resumeLink": resumeLink,
        }),
      );
      return true;
    } catch (error) {
      log('Error in application service: $error');
      return false;
    }
  }

  //? Function to accept a specific application
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

  //? Function to reject a specific application
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

  Future<List<ApplicationStorage>> fetchAllApplicatons() async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/application/',
        headers: headers,
        method: HttpMethod.get,
      ) as List<dynamic>;
      // Convert each element in List<dynamic> to List<Map<String, dynamic>>
      final responseMapList = List<Map<String, dynamic>>.from(response);
      // Convert each element to ApplicationStorage type,
      // Each storage corresponds to a jobposting
      final storageList = responseMapList
          .map((storage) => ApplicationStorage.fromJson(storage))
          .toList();
      return storageList;
    } catch (error) {
      Utils.logMessage('Error in fetchAllApplications: $error');
      return [];
    }
  }

  // Function to get the information of ApplicationStorage based on id
  Future<ApplicationStorage?> getApplicationStorageById(String id) async {
    try {
      final response = await httpFetch(
        '$databaseUrl/api/application/$id',
        headers: headers,
        method: HttpMethod.get,
      ) as Map<String, dynamic>;
      // Convert response to ApplicationStorage type
      final storage = ApplicationStorage.fromJson(response);
      return storage;
    } catch (error) {
      Utils.logMessage('Error in getApplicationStorage server: $error');
      return null;
    }
  }
}
