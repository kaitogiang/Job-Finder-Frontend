import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/jobseeker/resume_preview/resume_creation_method.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class ResumeCreationForm extends StatefulWidget {
  const ResumeCreationForm({super.key});

  @override
  State<ResumeCreationForm> createState() => _ResumeCreationFormState();
}

class _ResumeCreationFormState extends State<ResumeCreationForm> {
  late Jobseeker _jobseeker;
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _descControllerList = [];
  final TextEditingController _fileNameController = TextEditingController();
  final ValueNotifier<bool> _isTypingDesiredPosition = ValueNotifier(false);
  
  int _numberOfExp = 0;
  int _numberOfEdu = 0;

  @override
  void initState() {
    super.initState();
    _jobseeker = context.read<JobseekerManager>().jobseeker;
    
    // Initialize basic info fields
    _nameController.text = '${_jobseeker.firstName} ${_jobseeker.lastName}';
    _addressController.text = _jobseeker.address;
    _phoneController.text = _jobseeker.phone;
    _emailController.text = _jobseeker.email;
    
    // Initialize experience and education fields
    _numberOfExp = _jobseeker.experience.length;
    _numberOfEdu = _jobseeker.education.length;
    _descControllerList.addAll(List<TextEditingController>.generate(
        _numberOfExp, (index) => TextEditingController()));

    // Add listener for filename field
    _fileNameController.addListener(_onFileNameChanged);
  }

  void _onFileNameChanged() {
    _isTypingDesiredPosition.value = _fileNameController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _fileNameController.dispose();
    for (var controller in _descControllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if keyboard is hidden to unfocus all fields
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (bottomInset == 0.0) {
      _unfocusAll();
    }
  }

  void _unfocusAll() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _previewResume() async {
    FocusScope.of(context).unfocus();
    Utils.logMessage(FocusScope.of(context).hasFocus.toString());

    if (!_isTypingDesiredPosition.value) {
      _showErrorAlert('Không thể xem trước CV', 'Vui lòng nhập vào trường bắt buộc');
      return;
    }

    final optionalExpDescription = _descControllerList.map((controller) => controller.text).toList();
    final position = _fileNameController.text;
    
    Map<String, dynamic> data = {
      'jobseeker': _jobseeker,
      'experienceDesc': optionalExpDescription,
      'position': position,
    };
    
    context.pushNamed('resume-creation-preview', extra: data);
  }

  void _showErrorAlert(String title, String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: title,
      text: message,
      confirmBtnText: 'Tôi biết rồi',
    );
  }

  Future<void> _createResumePdf() async {
    if (!_isTypingDesiredPosition.value) {
      _showErrorAlert('Không thể tạo CV', 'Vui lòng điền thông tin bắt buộc');
      return;
    }

    try {
      QuickAlert.show(
        context: context, 
        type: QuickAlertType.loading, 
        title: 'Đang tạo...'
      );

      final optionalExpDescription = _descControllerList.map((controller) => controller.text).toList();
      final position = _fileNameController.text;
      final format = PdfPageFormat.a4;
      
      final bytes = await generateResume(format, position, _jobseeker, optionalExpDescription);
      
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;
      final tempFile = File('$tempPath/tempResume.pdf');
      await tempFile.writeAsBytes(bytes);
      
      Utils.logMessage('Save as file ${tempFile.path}...');
      
      final fileName = '${position}_${_jobseeker.firstName}_${_jobseeker.lastName}'
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');

      if (mounted) {
        await context.read<JobseekerManager>().uploadResume(fileName, tempFile);
        Utils.logMessage('Tạo CV mới thành công');
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.settings.name == 'resume-list');
      }

      await tempFile.delete();
      
    } catch (error) {
      Utils.logMessage('Error in _createResumePdf: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceSize = MediaQuery.of(context).size;
    
    final experiences = _jobseeker.experience;
    final educations = _jobseeker.education;
    final skills = _jobseeker.skills;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tạo CV",
          style: textTheme.titleLarge!.copyWith(
            color: theme.indicatorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.remove_red_eye_rounded,
              color: Colors.white,
            ),
            onPressed: _previewResume,
            tooltip: 'Xem trước',
          ),
          const SizedBox(width: 10),
        ],
        elevation: 0,
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.yellow.shade400.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.yellow.shade900,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hãy kiểm tra thông tin lại trước khi tạo CV mới. Bạn có thể thiết lập thêm các thông tin bổ sung.',
                        style: textTheme.bodyLarge!.copyWith(
                          color: Colors.yellow.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              Text(
                'Vị trí muốn ứng tuyển?',
                style: textTheme.titleMedium!.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 5),
              
              TextFormField(
                controller: _fileNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Nhập vào vị trí muốn ứng tuyển (Bắt buộc)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  suffixIcon: ValueListenableBuilder(
                    valueListenable: _isTypingDesiredPosition,
                    builder: (context, isTyping, child) {
                      return !isTyping
                          ? Container(
                              width: 10,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                '*',
                                style: textTheme.bodyLarge!.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            )
                          : const SizedBox.shrink();
                    }
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Personal Information Section
              _buildSectionTitle(
                title: 'Thông tin cá nhân'.toUpperCase(),
                icon: Icons.person,
                textTheme: textTheme
              ),
              const SizedBox(height: 10),

              CombinedTextFormField(
                title: 'Họ tên',
                hintText: 'Họ tên của bản',
                controller: _nameController,
                keyboardType: TextInputType.name,
                isRead: true,
              ),
              const SizedBox(height: 8),

              CombinedTextFormField(
                title: 'Email',
                hintText: 'Email của bạn',
                controller: _emailController,
                keyboardType: TextInputType.name,
                isRead: true,
              ),
              const SizedBox(height: 8),

              CombinedTextFormField(
                title: 'Số điện thoại',
                hintText: 'Số điện thoại của bạn',
                controller: _phoneController,
                keyboardType: TextInputType.name,
                isRead: true,
              ),
              const SizedBox(height: 8),

              CombinedTextFormField(
                title: 'Địa chỉ',
                hintText: 'Địa chỉ của bạn',
                controller: _addressController,
                keyboardType: TextInputType.name,
                isRead: true,
              ),
              const SizedBox(height: 10),

              // Work Experience Section  
              _buildSectionTitle(
                title: 'Kinh nghiệm làm việc'.toUpperCase(),
                icon: Icons.work,
                textTheme: textTheme
              ),
              const SizedBox(height: 10),

              ...List<Padding>.generate(_numberOfExp, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ExperienceFormDetail(
                    company: experiences[index].company,
                    duration: experiences[index].duration,
                    position: experiences[index].role,
                    controller: _descControllerList[index],
                  ),
                );
              }),
              const SizedBox(height: 10),

              // Education Section
              _buildSectionTitle(
                title: 'Học vấn'.toUpperCase(),
                icon: Icons.school,
                textTheme: textTheme
              ),
              const SizedBox(height: 10),

              ...List<Padding>.generate(_numberOfEdu, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: EducationFormDetail(
                    school: educations[index].school,
                    duration: '${educations[index].startDate} - ${educations[index].endDate}',
                    degree: educations[index].degree,
                    specialization: educations[index].specialization,
                  ),
                );
              }),

              // Skills Section
              _buildSectionTitle(
                title: 'Kỹ năng'.toUpperCase(),
                icon: Icons.code,
                textTheme: textTheme
              ),
              const SizedBox(height: 10),

              Wrap(
                alignment: WrapAlignment.start,
                spacing: 5,
                runSpacing: 3,
                children: List<Widget>.generate(skills.length, (index) {
                  return InputChip(
                    label: Text(
                      skills[index],
                      overflow: TextOverflow.ellipsis,
                    ),
                    labelStyle: const TextStyle(color: Colors.black),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Center(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          fixedSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: theme.primaryColor,
                        ),
                        onPressed: _createResumePdf,
                        child: Text(
                          'Tạo CV',
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        fixedSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _previewResume,
                      child: Text(
                        'Xem trước',
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  RichText _buildSectionTitle({
    required String title,
    required IconData icon,
    required TextTheme textTheme,
  }) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              icon,
              color: Colors.black54,
            )
          ),
          const WidgetSpan(
            child: SizedBox(width: 8)
          ),
          TextSpan(
            text: title,
            style: textTheme.titleMedium!.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )
          )
        ]
      ),
    );
  }
}

class ExperienceFormDetail extends StatefulWidget {
  const ExperienceFormDetail({
    super.key,
    required this.controller,
    required this.duration,
    required this.company,
    required this.position,
  });

  final TextEditingController controller;
  final String duration;
  final String position;
  final String company;

  @override
  State<ExperienceFormDetail> createState() => _ExperienceFormDetailState();
}

class _ExperienceFormDetailState extends State<ExperienceFormDetail> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _companyController.text = widget.company;
    _positionController.text = widget.position;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.timelapse_rounded,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              widget.duration,
              style: textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        CombinedTextFormField(
          title: 'Công ty',
          hintText: 'Công ty của bạn',
          controller: _companyController,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(height: 8),

        CombinedTextFormField(
          title: 'Vị trí',
          hintText: 'Vị trí của bạn',
          controller: _positionController,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(height: 16),

        Text(
          'Mô tả thêm',
          style: textTheme.titleMedium!.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 5),

        TextFormField(
          controller: widget.controller,
          minLines: 3,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Mô tả thêm về vị trí đã làm (Tùy chọn)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class EducationFormDetail extends StatefulWidget {
  const EducationFormDetail({
    super.key,
    required this.school,
    required this.specialization,
    required this.degree,
    required this.duration,
  });

  final String school;
  final String specialization;
  final String degree;
  final String duration;

  @override
  State<EducationFormDetail> createState() => _EducationFormDetailState();
}

class _EducationFormDetailState extends State<EducationFormDetail> {
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _schoolController.text = widget.school;
    _degreeController.text = widget.degree;
    _specializationController.text = widget.specialization;
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _degreeController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.timelapse_rounded,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              widget.duration,
              style: textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        CombinedTextFormField(
          title: 'Trường',
          hintText: 'Trường của bạn',
          controller: _schoolController,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(height: 8),

        CombinedTextFormField(
          title: 'Chuyên ngành',
          hintText: 'Chuyên ngành của bạn',
          controller: _specializationController,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(height: 8),

        CombinedTextFormField(
          title: 'Bằng cấp',
          hintText: 'Bằng cấp của bạn',
          controller: _degreeController,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
