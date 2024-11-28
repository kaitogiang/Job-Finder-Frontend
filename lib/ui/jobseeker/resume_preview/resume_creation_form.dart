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
  late Jobseeker jobseeker;
  //Thiết lập các Controller
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _descControllerList = <TextEditingController>[];
  final _fileNameController = TextEditingController();
  final _isTypingDesiredPosition = ValueNotifier(false);
  int numberOfExp = 0;
  int numberOfEdu = 0;
  @override
  void initState() {
    super.initState();
    jobseeker = context.read<JobseekerManager>().jobseeker;
    //Khởi tạo thông tin các trường thông tin cơ bản
    _nameController.text = '${jobseeker.firstName} ${jobseeker.lastName}';
    _addressController.text = jobseeker.address;
    _phoneController.text = jobseeker.phone;
    _emailController.text = jobseeker.email;
    //Khởi tạo thông tin kinh nghiệm làm việc
    //Tạo ra các controller cho các trường nhập thông tin bổ sung trong
    //Kinh nghiệm làm việc
    numberOfExp = jobseeker.experience.length;
    numberOfEdu = jobseeker.education.length;
    _descControllerList.addAll(List<TextEditingController>.generate(
        numberOfExp, (index) => TextEditingController()));

    //Lắng nghe sự kiện
    _fileNameController.addListener(() {
      if (_fileNameController.text.isEmpty) {
        _isTypingDesiredPosition.value = false;
      } else {
        _isTypingDesiredPosition.value = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //Quan sát xem khi mà người dùng nhấn ẩn keyboard đi thì bottomInsets sẽ là 0
    //Nếu là 0 thì bỏ focus tất cả các trường
    //didChangeDependencies sẽ được gọi nếu các widget bên trong có sự rebuild lại
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    if (bottomInset == 0.0) {
      // If keyboard is closed, unfocus all text fields
      _unfocusAll();
    }
  }

  // Unfocus all fields
  void _unfocusAll() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _previewResume() async {
    FocusScope.of(context).unfocus();
    Utils.logMessage(FocusScope.of(context).hasFocus.toString());
    //Kiểm tra xem những trường bắt buộc điền có chưa, nếu chưa thì báo lỗi
    if (_isTypingDesiredPosition.value == false) {
      //Báo lỗi tại vì chưa nhập vào tên vị trí muốn ứng tuyển
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Không thể xem trước CV',
        text: 'Vui lòng nhập vào trường bắt buộc',
        confirmBtnText: 'Tôi biết rồi',
      );
      return;
    }
    //Trích xuât các phần mô tả thêm và đối tượng jobseeker
    List<String> optionalExpDescription =
        _descControllerList.map((controller) => controller.text).toList();
    final position = _fileNameController.text;
    Map<String, dynamic> data = {
      'jobseeker': jobseeker,
      'experienceDesc': optionalExpDescription,
      'position': position,
    };
    context.pushNamed('resume-creation-preview', extra: data);
  }

  Future<void> _createResumePdf() async {
    //Kiểm tra xem những trường bắt buộc điền có chưa, nếu chưa thì báo lỗi
    if (_isTypingDesiredPosition.value == false) {
      //Báo lỗi tại vì chưa nhập vào tên vị trí muốn ứng tuyển
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Không thể tạo CV',
        text: 'Vui lòng điền thông tin bắt buộc',
        confirmBtnText: 'Tôi biết rồi',
      );
      return;
    }
    try {
      QuickAlert.show(
          context: context, type: QuickAlertType.loading, title: 'Đang tạo...');
      //Trích xuât các phần mô tả thêm và đối tượng jobseeker
      List<String> optionalExpDescription =
          _descControllerList.map((controller) => controller.text).toList();
      final position = _fileNameController.text;
      final format =
          PdfPageFormat.a4; // Specify the page format (e.g., A4, Letter, etc.)
      final bytes = await generateResume(format, position, jobseeker,
          optionalExpDescription); //Tạo bytes file PDF
      //Tiến hành tạo file PDF tạm trong thư mục tạm và sau khi upload xong thì bỏ
      //Lấy thư mục tạm
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;

      //Tạo file PDF trong đường dẫn này
      final tempFile = File('$tempPath/tempResume.pdf');
      await tempFile.writeAsBytes(bytes);
      Utils.logMessage('Save as file ${tempFile.path}...');
      final fileName =
          '${position}_${jobseeker.firstName}_${jobseeker.lastName}'
              .trim()
              .replaceAll(RegExp(r'\s+'), '_');
      //Gọi API lưu file vào Server
      if (mounted) {
        await context.read<JobseekerManager>().uploadResume(fileName, tempFile);
        Utils.logMessage('Tạo CV mới thành công');
      }
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .popUntil((route) => route.settings.name == 'resume-list');
      }
      //Xóa file tạm sau khi đã upload lên server
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
    //Lấy dữ liệu education và experience
    final experiences = jobseeker.experience;
    final educations = jobseeker.education;
    final skills = jobseeker.skills;
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
            icon: Icon(
              Icons.remove_red_eye_rounded,
              color: Colors.white,
            ),
            onPressed: _previewResume,
            tooltip: 'Xem trước',
          ),
          const SizedBox(
            width: 10,
          ),
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
                ]),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.yellow.shade900,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
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
              const SizedBox(
                height: 10,
              ),
              //Đặt tên cho vị trí muốn ứng tuyển
              Text(
                'Vị trí muốn ứng tuyển?',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _fileNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Nhập vào vị trí muốn ứng tuyển (Bắt buộc)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
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
                            : SizedBox.shrink();
                      }),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              //Phần hiển thị thông tin cá nhân
              _buildSectionTitle(
                  title: 'Thông tin cá nhân'.toUpperCase(),
                  icon: Icons.person,
                  textTheme),
              const SizedBox(
                height: 10,
              ),
              CombinedTextFormField(
                title: 'Họ tên',
                hintText: 'Họ tên của bản',
                controller: _nameController,
                keyboardType: TextInputType.name,
                isRead: true,
              ),
              const SizedBox(
                height: 8,
              ),
              CombinedTextFormField(
                title: 'Email',
                hintText: 'Email của bạn',
                controller: _emailController,
                keyboardType: TextInputType.name,
                isRead: true,
              ),
              const SizedBox(
                height: 8,
              ),
              CombinedTextFormField(
                title: 'Số điện thoại',
                hintText: 'Số điện thoại của bạn',
                controller: _phoneController,
                keyboardType: TextInputType.name,
                isRead: true,
              ),
              const SizedBox(
                height: 8,
              ),
              CombinedTextFormField(
                title: 'Địa chỉ',
                hintText: 'Địa chỉ của bạn',
                controller: _addressController,
                keyboardType: TextInputType.name,
                isRead: true,
              ),
              const SizedBox(
                height: 10,
              ),
              //Phần hiển thị thông tin các kinh nghiệm làm việc
              _buildSectionTitle(
                  title: 'Kinh nghiệm làm việc'.toUpperCase(),
                  icon: Icons.work,
                  textTheme),
              const SizedBox(
                height: 10,
              ),
              ...List<Padding>.generate(numberOfExp, (index) {
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
              const SizedBox(
                height: 10,
              ),
              //Hiển thị học vấn
              _buildSectionTitle(
                  title: 'Học vấn'.toUpperCase(),
                  icon: Icons.school,
                  textTheme),
              const SizedBox(
                height: 10,
              ),
              ...List<Padding>.generate(numberOfEdu, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: EducationFormDetail(
                    school: educations[index].school,
                    duration:
                        '${educations[index].startDate} - ${educations[index].endDate}',
                    degree: educations[index].degree,
                    specialization: educations[index].specialization,
                  ),
                );
              }),
              _buildSectionTitle(
                  title: 'Kỹ năng'.toUpperCase(), icon: Icons.code, textTheme),
              const SizedBox(
                height: 10,
              ),
              //Hiển thị danh sách các kỹ năng
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
                    labelStyle: TextStyle(color: Colors.black),
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 20,
              ),
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
                    const SizedBox(
                      width: 5,
                    ),
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

  RichText _buildSectionTitle(TextTheme textTheme,
      {required String title, required IconData icon}) {
    return RichText(
      text: TextSpan(children: [
        WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              icon,
              color: Colors.black54,
            )),
        const WidgetSpan(
            child: SizedBox(
          width: 8,
        )),
        TextSpan(
            text: title,
            style: textTheme.titleMedium!.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ))
      ]),
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
  final _companycontroller = TextEditingController();
  final _positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _companycontroller.text = widget.company;
    _positionController.text = widget.position;
  }

  @override
  void dispose() {
    super.dispose();
    _companycontroller.dispose();
    _positionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timelapse_rounded,
              color: Colors.blue,
            ),
            const SizedBox(
              width: 8,
            ),
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
        const SizedBox(
          height: 8,
        ),
        CombinedTextFormField(
          title: 'Công ty',
          hintText: 'Công ty của bạn',
          controller: _companycontroller,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(
          height: 8,
        ),
        CombinedTextFormField(
          title: 'Vị trí',
          hintText: 'Vị trí của bạn',
          controller: _positionController,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(
          height: 8,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          'Mô tả thêm',
          style: textTheme.titleMedium!.copyWith(
            fontSize: 17,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
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
              borderSide: BorderSide(
                color: Colors.blue,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.blue,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
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
  final _schoolController = TextEditingController();
  final _degreeController = TextEditingController();
  final _specializationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _schoolController.text = widget.school;
    _degreeController.text = widget.degree;
    _specializationController.text = widget.specialization;
  }

  @override
  void dispose() {
    super.dispose();
    _schoolController.dispose();
    _degreeController.dispose();
    _specializationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.timelapse_rounded,
              color: Colors.blue,
            ),
            const SizedBox(
              width: 8,
            ),
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
        const SizedBox(
          height: 8,
        ),
        CombinedTextFormField(
          title: 'Trường',
          hintText: 'Trường của bạn',
          controller: _schoolController,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(
          height: 8,
        ),
        CombinedTextFormField(
          title: 'Chuyên ngành',
          hintText: 'Chuyên ngành của bạn',
          controller: _specializationController,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(
          height: 8,
        ),
        CombinedTextFormField(
          title: 'Bằng cấp',
          hintText: 'Bằng cấp của bạn',
          controller: _degreeController,
          keyboardType: TextInputType.name,
          isRead: true,
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
