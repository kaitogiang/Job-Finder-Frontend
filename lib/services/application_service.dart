import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:job_finder_app/models/auth_token.dart';
import 'package:job_finder_app/services/node_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

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

  // Future<void> downloadFile(String url, String filename) async {
  //   try {
  //     final completeUrl = '$databaseUrl/$url';

  //     final response = await http.head(Uri.parse(completeUrl));
  //     if (response.statusCode == 200) {
  //       FileDownloader.downloadFile(
  //         url:
  //             'http://192.168.1.104:3000/pdfs/jobseeker-1717601317184-737476261.pdf',
  //         onProgress: (fileName, progress) {
  //           log('FILE has progress $progress');
  //         },
  //         onDownloadCompleted: (path) {
  //           log('File được tải tại thư mục Download');
  //         },
  //         onDownloadError: (errorMessage) {
  //           log('Download ERROR: $errorMessage');
  //         },
  //       );
  //     }
  //   } catch (error) {
  //     log('Error in application service: $error');
  //   }
  // }
}
