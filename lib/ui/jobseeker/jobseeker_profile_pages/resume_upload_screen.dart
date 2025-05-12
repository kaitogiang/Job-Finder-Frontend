import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/models/resume.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/resume_infor_card.dart';
import 'package:job_finder_app/ui/shared/loading_screen.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

class ResumeUploadScreen extends StatefulWidget {
  final Resume? resume;

  const ResumeUploadScreen({super.key, this.resume});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        final filename = basename(_selectedFile!.path);
        Utils.logMessage('Selected file: ${_selectedFile!.path}');
        Utils.logMessage('Filename: $filename');
      });
    }
  }

  Future<void> _uploadFile(BuildContext context) async {
    if (_selectedFile == null) return;

    try {
      LoadingScreen();
      final filename = basename(_selectedFile!.path);
      await context.read<JobseekerManager>().uploadResume(filename, _selectedFile!);
      Utils.logMessage('Upload successful');
      
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      Utils.logMessage('Resume upload error: $error');
    }
  }

  Future<void> _deleteFile(BuildContext context) async {
    try {
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      Utils.logMessage('Resume delete error: $error');
    }
  }

  Widget _buildUploadButton(BuildContext context, ThemeData theme, Size deviceSize) {
    return ElevatedButton(
      onPressed: () {
        if (_selectedFile != null && widget.resume == null) {
          _uploadFile(context);
        } else if (_selectedFile == null && widget.resume != null) {
          Navigator.of(context).pop();
        } else if (_selectedFile == null && widget.resume == null) {
          _deleteFile(context);
        }
      },
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: Colors.grey.shade300,
        fixedSize: Size(deviceSize.width, 60),
        backgroundColor: theme.primaryColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        foregroundColor: theme.colorScheme.onPrimary,
        textStyle: theme.textTheme.titleMedium,
      ),
      child: const Text("LƯU"),
    );
  }

  Widget _buildDottedUploadArea(ThemeData theme, TextTheme textTheme, Size deviceSize) {
    return DottedBorder(
      color: theme.primaryColor,
      borderType: BorderType.RRect,
      radius: const Radius.circular(10),
      strokeWidth: 1,
      child: InkWell(
        onTap: _pickFile,
        borderRadius: BorderRadius.circular(10),
        splashColor: theme.colorScheme.secondary,
        child: Container(
          width: deviceSize.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.cloud_upload,
                color: theme.primaryColor,
                size: 70,
              ),
              Text(
                'Tải lên CV của bạn tại đây',
                style: textTheme.titleMedium,
              ),
              SizedBox(
                width: deviceSize.width - 50,
                child: Text(
                  'Chỉ hổ trợ định dạng tệp tin PDF dưới 2MB. Bạn chỉ được phép tải duy nhất 1 file',
                  style: textTheme.bodyLarge!.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  ListView _buildActionButton({
    required BuildContext context,
    void Function()? onDelete,
    void Function()? onPreview,
  }) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text(
            'Xóa bỏ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: const Icon(Icons.delete),
          onTap: onDelete,
        ),
        const Divider(),
        ListTile(
          title: Text(
            'Xem trước',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: const Icon(Icons.preview),
          onTap: onPreview,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV của tôi'),
      ),
      body: Container(
        width: deviceSize.width,
        height: deviceSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Hồ sơ ứng tuyển',
                style: textTheme.titleMedium!.copyWith(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            (_selectedFile != null || widget.resume != null)
                ? ResumeInforCard(
                    resume: Resume(
                      fileName: _selectedFile != null 
                        ? basename(_selectedFile!.path)
                        : widget.resume?.fileName ?? '',
                      url: widget.resume?.url ?? '',
                      uploadedDate: widget.resume?.uploadedDate ?? DateTime.now(),
                    ),
                    onAction: () {
                      showAdditionalScreen(
                        context: context,
                        title: 'Tùy chọn',
                        child: _buildActionButton(
                          context: context,
                          onDelete: () {
                            Utils.logMessage('Delete file');
                            setState(() {
                              _selectedFile = null;
                            });
                            Navigator.pop(context);
                          },
                          onPreview: () {
                            Utils.logMessage('Preview file');
                            Navigator.pop(context);
                          },
                        ),
                        heightFactor: 0.3,
                      );
                    },
                  )
                : _buildDottedUploadArea(theme, textTheme, deviceSize),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildUploadButton(context, theme, deviceSize),
              ),
            )
          ],
        ),
      ),
    );
  }
}
