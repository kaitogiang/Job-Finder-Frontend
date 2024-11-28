import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/ui/jobseeker/resume_preview/resume_creation_method.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class ResumeCreationPreview extends StatefulWidget {
  const ResumeCreationPreview({super.key, required this.data});

  final Map<String, dynamic> data;
  @override
  State<ResumeCreationPreview> createState() => _ResumeCreationPreviewState();
}

class _ResumeCreationPreviewState extends State<ResumeCreationPreview> {
  late Jobseeker jobseeker;
  late List<String> experienceDesc;
  late String position;

  @override
  void initState() {
    super.initState();
    jobseeker = widget.data['jobseeker'] as Jobseeker;
    experienceDesc = widget.data['experienceDesc'] as List<String>;
    position = widget.data['position'] as String;
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Hàm lưu file PDF
  Future<void> _saveAsFile(BuildContext context, LayoutCallback build,
      PdfPageFormat pageFormat) async {
    try {
      final bytes = await build(pageFormat);
      if (await _requestPermission()) {
        //? Tải vào thư mục Download public của điện thoại
        String path = '/storage/emulated/0/Download';
        String fileName =
            '${position}_${jobseeker.firstName}_${jobseeker.lastName}'
                .trim()
                .replaceAll(RegExp(r'\s+'),
                    '_'); //Tên file phải hợp lý thì mới lưu được
        String fullPath = '$path/$fileName.pdf';
        //Tạo File PDF từ fullPath bên trên
        File file = File(fullPath);
        //Lưu file vào thư mục download
        await file.writeAsBytes(bytes);
        Utils.logMessage('Save as file ${file.path}...');
        await file.writeAsBytes(bytes);
        Utils.logMessage('FilePath: ${file.path}');
        _createNotification(file.path);
        await OpenFile.open(file.path);
      }
    } catch (error) {
      Utils.logMessage('Error in _saveAsFile: $error');
    }
  }

  void _createNotification(String path) {
    final Map<String, String> data = {
      'type': 'download_notification',
    };
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().microsecond,
        channelKey: 'basic_channel',
        title: 'Tải xuống CV thành công',
        body: 'Tệp tin được tải xuống tại: $path',
        payload: data,
      ),
    );
  }

  //Hàm lưu file vào cơ sở dữ liệu
  // Future<void> _saveToDatabase(BuildContext context, LayoutCallback build,
  //     PdfPageFormat pageFormat) async {
  //   try {
  //     final bytes = await build(pageFormat);
  //     if (await _requestPermission()) {
  //       //? Tải vào thư mục Download public của điện thoại
  //       String path = '/storage/emulated/0/Download';
  //       String fileName = 'document_3'; //Tên file phải hợp lý thì mới lưu được
  //       String fullPath = '$path/$fileName.pdf';

  //       //Tạo File PDF từ fullPath bên trên
  //       File file = File(fullPath);
  //       //Lưu file vào thư mục download
  //       await file.writeAsBytes(bytes);
  //       Utils.logMessage('Save as file ${file.path}...');
  //       await file.writeAsBytes(bytes);
  //       Utils.logMessage('FilePath: ${file.path}');
  //       await OpenFile.open(file.path);
  //     }
  //   } catch (error) {
  //     Utils.logMessage('Error in _saveAsFile: $error');
  //   }
  // }

  Future<bool> _requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        Utils.logMessage('Status la: $status');
        return status.isGranted;
      } else {
        return true;
      }
    } catch (error) {
      Utils.logMessage('Error in application service: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Xem trước CV',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            width: deviceSize.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blueAccent.shade700,
                    Colors.blueAccent.shade400,
                    theme.primaryColor,
                  ]),
            ),
          ),
        ),
        body: PdfPreview(
          maxPageWidth: 700,
          build: (format) =>
              generateResume(format, position, jobseeker, experienceDesc),
          allowPrinting: false,
          allowSharing: false,
          canChangeOrientation: false,
          canChangePageFormat: false,
          dynamicLayout: false,
          
          onZoomChanged: (value) {
            Utils.logMessage('Zoom PDF: $value');
          },
          actions: <PdfPreviewAction>[
            PdfPreviewAction(
              icon: const Icon(Icons.download),
              onPressed: _saveAsFile,
            ),
          ],
          onPrinted: (context) {
            Utils.logMessage('In file PDF');
          },
        ));
  }
}
