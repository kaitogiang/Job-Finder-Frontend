import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/models/resume.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/resume_infor_card.dart';
import 'package:job_finder_app/ui/shared/loading_screen.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:quickalert/quickalert.dart';

class ResumeListScreen extends StatefulWidget {
  const ResumeListScreen({super.key});

  @override
  State<ResumeListScreen> createState() => _ResumeListScreenState();
}

class _ResumeListScreenState extends State<ResumeListScreen> {
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

  Future<void> _deleteResume(BuildContext context, int index) async {
    try {
      await context.read<JobseekerManager>().deleteResume(index);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      Utils.logMessage('Trong resume delete file ${error.toString()}');
    }
  }

  void _goToResumeCreation(BuildContext context, Jobseeker jobseeker) {
    //Kiểm tra xem người dùng đã thiết lập đủ thông tin như kinh nghiệm, học vấn, kỹ năng chưa, nếu chưa thì
    //báo lỗi yêu cầu thiết lập lại trước khi tạo
    //Nếu rồi thì cho phép chuyển hướng đến trang tạo CV
    if (jobseeker.education.isEmpty ||
        jobseeker.experience.isEmpty ||
        jobseeker.skills.isEmpty) {
      //Hiển thị thông báo và bỏ qua việc chuyển hướng
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Không thể tạo CV',
        text: 'Vui lòng thiết lập đầy đủ thông tin trước khi tạo CV',
        confirmBtnText: 'Tôi biết rồi',
      );
      return;
    }
    //Chuyển hướng đến trang tạo CV
    //Mở trang thêm CV mới
    context.pushNamed('resume-creation');
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    Size deviceSize = MediaQuery.of(context).size;
    final jobseekerManager = context.read<JobseekerManager>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CV của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: Colors.white,
            ),
            onPressed: () {
              _goToResumeCreation(context, jobseekerManager.jobseeker);
            },
            tooltip: 'Tạo CV mới',
          ),
        ],
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
      body: Consumer<JobseekerManager>(
          builder: (context, jobseekerManager, child) {
        final resumes = jobseekerManager.resumes;
        return Container(
          width: deviceSize.width,
          height: deviceSize.height,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (resumes.isNotEmpty)
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: resumes.length,
                        itemBuilder: (context, index) {
                          return ResumeInforCard(
                            resume: Resume(
                              fileName: resumes[index].fileName,
                              url: resumes[index].url,
                              uploadedDate: resumes[index].uploadedDate,
                            ),
                            onAction: () {
                              showAdditionalScreen(
                                  context: context,
                                  title: 'Tùy chọn',
                                  child: _buildActionButton(
                                    context: context,
                                    onDelete: () {
                                      Utils.logMessage('Xóa bỏ fie');
                                      _deleteResume(context, index);
                                      Navigator.pop(context);
                                    },
                                    onPreview: () {
                                      Utils.logMessage('Xem trước file');
                                      Navigator.pop(context);
                                      final url = resumes[index].url;
                                      context.pushNamed('resume-preview',
                                          extra: url);
                                    },
                                  ),
                                  heightFactor: 0.3);
                            },
                          );
                        },
                      ),
                    )
                  : DottedBorder(
                      color: theme.primaryColor,
                      borderType: BorderType.RRect,
                      radius: Radius.circular(10),
                      strokeWidth: 1,
                      child: InkWell(
                        onTap: () {
                          _goToResumeCreation(
                              context, jobseekerManager.jobseeker);
                        },
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
                                Icons.difference_outlined,
                                color: theme.primaryColor,
                                size: 60,
                              ),
                              Text(
                                'Tạo file CV của bạn tại đây',
                                style: textTheme.titleMedium,
                              ),
                              SizedBox(
                                width: deviceSize.width - 50,
                                child: Text(
                                  'Vui lòng thiết lập đầy đủ thông tin trước khi tạo CV',
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
              if (resumes.isEmpty) const Spacer(),
              if (resumes.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () {
                      // if (_selectedFile != null && widget.resume == null) {
                      //   _uploadFile(context);
                      // }
                      // if (_selectedFile == null && widget.resume != null) {
                      //   Navigator.of(context).pop();
                      // } else if (_selectedFile == null && widget.resume == null) {
                      //   _deleteFile(context);
                      // }
                      //Mở trang thêm CV mới
                      context.pushNamed('resume-creation');
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
                    child: Text("THÊM CV"),
                  ),
                )
            ],
          ),
        );
      }),
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
