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
  late final Jobseeker _jobseeker;
  late final List<String> _experienceDesc;
  late final String _position;

  @override
  void initState() {
    super.initState();
    _jobseeker = widget.data['jobseeker'] as Jobseeker;
    _experienceDesc = widget.data['experienceDesc'] as List<String>;
    _position = widget.data['position'] as String;
  }

  Future<void> _saveAsFile(BuildContext context, LayoutCallback build, PdfPageFormat pageFormat) async {
    try {
      final bytes = await build(pageFormat);
      if (!await _requestPermission()) {
        return;
      }

      final fileName = _generateFileName();
      final filePath = await _saveFileToDownloads(bytes, fileName);
      
      if (filePath != null) {
        _showDownloadNotification(filePath);
        await OpenFile.open(filePath);
      }
    } catch (error) {
      Utils.logMessage('Error in _saveAsFile: $error');
    }
  }

  String _generateFileName() {
    return '${_position}_${_jobseeker.firstName}_${_jobseeker.lastName}'
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
  }

  Future<String?> _saveFileToDownloads(List<int> bytes, String fileName) async {
    try {
      final path = '/storage/emulated/0/Download';
      final fullPath = '$path/$fileName.pdf';
      final file = File(fullPath);
      
      await file.writeAsBytes(bytes);
      Utils.logMessage('Saved file to: ${file.path}');
      
      return file.path;
    } catch (e) {
      Utils.logMessage('Error saving file: $e');
      return null;
    }
  }

  void _showDownloadNotification(String path) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().microsecond,
        channelKey: 'basic_channel',
        title: 'Tải xuống CV thành công',
        body: 'Tệp tin được tải xuống tại: $path',
        payload: {'type': 'download_notification'},
      ),
    );
  }

  Future<bool> _requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        Utils.logMessage('Permission status: $status');
        return status.isGranted;
      }
      return true;
    } catch (error) {
      Utils.logMessage('Error requesting permission: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildPdfPreview(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    
    return AppBar(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfPreview() {
    return PdfPreview(
      maxPageWidth: 700,
      build: (format) => generateResume(format, _position, _jobseeker, _experienceDesc),
      allowPrinting: false,
      allowSharing: false,
      canChangeOrientation: false,
      canChangePageFormat: false,
      dynamicLayout: false,
      onZoomChanged: (value) => Utils.logMessage('Zoom PDF: $value'),
      actions: <PdfPreviewAction>[
        PdfPreviewAction(
          icon: const Icon(Icons.download),
          onPressed: _saveAsFile,
        ),
      ],
      onPrinted: (context) => Utils.logMessage('In file PDF'),
    );
  }
}
