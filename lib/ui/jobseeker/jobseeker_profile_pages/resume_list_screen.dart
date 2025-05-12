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

  Future<void> _deleteResume(BuildContext context, int index) async {
    try {
      await context.read<JobseekerManager>().deleteResume(index);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      Utils.logMessage('Resume delete error: $error');
    }
  }

  void _goToResumeCreation(BuildContext context, Jobseeker jobseeker) {
    if (_isProfileIncomplete(jobseeker)) {
      _showIncompleteProfileAlert(context);
      return;
    }
    context.pushNamed('resume-creation');
  }

  bool _isProfileIncomplete(Jobseeker jobseeker) {
    return jobseeker.education.isEmpty || 
           jobseeker.experience.isEmpty || 
           jobseeker.skills.isEmpty;
  }

  void _showIncompleteProfileAlert(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Không thể tạo CV',
      text: 'Vui lòng thiết lập đầy đủ thông tin trước khi tạo CV',
      confirmBtnText: 'Tôi biết rồi',
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, Size deviceSize, TextTheme textTheme, JobseekerManager jobseekerManager) {
    return DottedBorder(
      color: theme.primaryColor,
      borderType: BorderType.RRect,
      radius: const Radius.circular(10),
      strokeWidth: 1,
      child: InkWell(
        onTap: () => _goToResumeCreation(context, jobseekerManager.jobseeker),
        borderRadius: BorderRadius.circular(10),
        splashColor: theme.colorScheme.secondary,
        child: Container(
          width: deviceSize.width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.difference_outlined, color: theme.primaryColor, size: 60),
              Text('Tạo file CV của bạn tại đây', style: textTheme.titleMedium),
              SizedBox(
                width: deviceSize.width - 50,
                child: Text(
                  'Vui lòng thiết lập đầy đủ thông tin trước khi tạo CV',
                  style: textTheme.bodyLarge!.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumeList(List<Resume> resumes) {
    return Expanded(
      child: ListView.builder(
        itemCount: resumes.length,
        itemBuilder: (context, index) {
          return ResumeInforCard(
            resume: Resume(
              fileName: resumes[index].fileName,
              url: resumes[index].url,
              uploadedDate: resumes[index].uploadedDate,
            ),
            onAction: () => _showResumeActions(context, index, resumes[index].url),
          );
        },
      ),
    );
  }

  void _showResumeActions(BuildContext context, int index, String url) {
    showAdditionalScreen(
      context: context,
      title: 'Tùy chọn',
      child: _buildActionButton(
        context: context,
        onDelete: () {
          _deleteResume(context, index);
          Navigator.pop(context);
        },
        onPreview: () {
          Navigator.pop(context);
          context.pushNamed('resume-preview', extra: url);
        },
      ),
      heightFactor: 0.3
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceSize = MediaQuery.of(context).size;
    final jobseekerManager = context.read<JobseekerManager>();

    return Scaffold(
      appBar: _buildAppBar(context, theme, deviceSize, jobseekerManager),
      body: Consumer<JobseekerManager>(
        builder: (context, jobseekerManager, child) {
          final resumes = jobseekerManager.resumes;
          
          return Container(
            width: deviceSize.width,
            height: deviceSize.height,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                resumes.isNotEmpty 
                  ? _buildResumeList(resumes)
                  : _buildEmptyState(context, theme, deviceSize, textTheme, jobseekerManager),
                
                if (resumes.isEmpty) const Spacer(),
                
                if (resumes.isNotEmpty)
                  _buildAddButton(context, theme, deviceSize, textTheme)
              ],
            ),
          );
        }
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, Size deviceSize, JobseekerManager jobseekerManager) {
    return AppBar(
      title: const Text(
        'CV của tôi',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.white),
          onPressed: () => _goToResumeCreation(context, jobseekerManager.jobseeker),
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
            ]
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, ThemeData theme, Size deviceSize, TextTheme textTheme) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ElevatedButton(
        onPressed: () => context.pushNamed('resume-creation'),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Colors.grey.shade300,
          fixedSize: Size(deviceSize.width, 60),
          backgroundColor: theme.primaryColor,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: theme.colorScheme.onPrimary,
          textStyle: textTheme.titleMedium
        ),
        child: const Text("THÊM CV"),
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
}
