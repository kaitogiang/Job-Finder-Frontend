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
  ResumeUploadScreen({super.key, this.resume});

  Resume? resume;

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //hàm dùng để thực hiện việc chọn file PDF
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        Utils.logMessage('File đã chọn ${_selectedFile!.path}');
        String filename = basename(_selectedFile!.path);
        Utils.logMessage('Tên file la: $filename');
      });
    }
  }

  // Hàm upload file lên trên server
  Future<void> _uploadFile(BuildContext context) async {
    if (_selectedFile != null) {
      //Todo Thực hiện các dịch vụ upload file
      String filename = basename(_selectedFile!.path);
      try {
        LoadingScreen();
        await context
            .read<JobseekerManager>()
            .uploadResume(filename, _selectedFile!);
        Utils.logMessage('Tải lên thành công');
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (error) {
        Utils.logMessage('Trong resume upload screen: ${error.toString()}');
      }
    }
  }

  Future<void> _deleteFile(BuildContext context) async {
    try {
      // await context.read<JobseekerManager>().deleteResume();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      Utils.logMessage('Trong resume delete file ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('CV của tôi'),
      ),
      body: Container(
        width: deviceSize.width,
        height: deviceSize.height,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
            const SizedBox(
              height: 10,
            ),
            (_selectedFile != null || widget.resume != null)
                ? ResumeInforCard(
                    resume: Resume(
                      fileName: (_selectedFile != null)
                          ? basename(_selectedFile!.path)
                          : (widget.resume != null
                              ? widget.resume!.fileName
                              : ''),
                      url: widget.resume != null ? widget.resume!.url : '',
                      uploadedDate: widget.resume != null
                          ? widget.resume!.uploadedDate
                          : DateTime.now(),
                    ),
                    onAction: () {
                      showAdditionalScreen(
                          context: context,
                          title: 'Tùy chọn',
                          child: _buildActionButton(
                            context: context,
                            onDelete: () {
                              Utils.logMessage('Xóa bỏ fie');
                              setState(() {
                                _selectedFile = null;
                                if (widget.resume != null) widget.resume = null;
                              });
                              Navigator.pop(context);
                            },
                            onPreview: () {
                              Utils.logMessage('Xem trước file');
                              Navigator.pop(context);
                            },
                          ),
                          heightFactor: 0.3);
                    },
                  )
                : DottedBorder(
                    color: theme.primaryColor,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(10),
                    strokeWidth: 1,
                    child: InkWell(
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(10),
                      splashColor: theme.colorScheme.secondary,
                      child: Container(
                        width: deviceSize.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
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
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
            //Nút dùng để lưu thay đổi vào cơ sở dữ liệu khi đã chọn file
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedFile != null && widget.resume == null) {
                      _uploadFile(context);
                    }
                    if (_selectedFile == null && widget.resume != null) {
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
                      textStyle: textTheme.titleMedium),
                  child: Text("LƯU"),
                ),
              ),
            )
          ],
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
          leading: Icon(Icons.delete),
          onTap: onDelete,
        ),
        Divider(),
        ListTile(
          title: Text(
            'Xem trước',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: Icon(Icons.preview),
          onTap: onPreview,
        ),
      ],
    );
  }
}
