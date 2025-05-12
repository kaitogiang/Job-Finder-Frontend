import 'dart:developer';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../../shared/addition_data.dart';

class EducationAdditionScreen extends StatefulWidget {
  final Education? education;

  EducationAdditionScreen({super.key, this.education});

  @override
  State<EducationAdditionScreen> createState() => _EducationAdditionScreenState();
}

class _EducationAdditionScreenState extends State<EducationAdditionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _schoolController = TextEditingController();
  final _specController = TextEditingController();
  final _selectedDegree = ValueNotifier<int>(-1);
  final isFull = ValueNotifier<bool>(false);
  
  late final List<String> _degrees;
  late final Education _education;
  late final bool _isEditScreen;
  late final int _educationIndex;
  bool _isDoing = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupControllerListeners();
    _populateFields();
  }

  void _initializeData() {
    _degrees = List<String>.from(getDegree());
    _education = widget.education ?? Education(
      specialization: '',
      school: '',
      degree: '',
      startDate: '',
      endDate: ''
    );
    _isEditScreen = _isEditMode();
    _educationIndex = _getEducationIndex();
    log('Index is: $_educationIndex');
  }

  bool _isEditMode() {
    return !(widget.education?.degree.isEmpty ?? true) ||
           !(widget.education?.school.isEmpty ?? true) ||
           !(widget.education?.specialization.isEmpty ?? true) ||
           !(widget.education?.startDate.isEmpty ?? true) ||
           !(widget.education?.endDate.isEmpty ?? true);
  }

  int _getEducationIndex() {
    if (!_isEditScreen) return -1;
    return context.read<JobseekerManager>()
        .jobseeker.education.indexOf(widget.education!);
  }

  void _setupControllerListeners() {
    _schoolController.addListener(_validateForm);
    _specController.addListener(_validateForm);
    _fromController.addListener(_validateForm);
    _toController.addListener(_validateForm);
  }

  void _populateFields() {
    if (widget.education != null) {
      _schoolController.text = widget.education!.school;
      _specController.text = widget.education!.specialization;
      _fromController.text = widget.education!.startDate;
      _toController.text = widget.education!.endDate;
      _selectedDegree.value = _degrees.indexOf(widget.education!.degree);
      _isDoing = widget.education!.endDate == 'Hiện nay';
    }
  }

  void _validateForm() {
    isFull.value = _schoolController.text.isNotEmpty &&
        _specController.text.isNotEmpty &&
        _fromController.text.isNotEmpty &&
        _toController.text.isNotEmpty;
  }

  bool _isValidDateRange(String fromDate, String toDate) {
    if (fromDate.isEmpty || toDate.isEmpty) return true;

    final from = _parseDate(fromDate);
    final to = _parseDate(toDate);
    return from.isBefore(to);
  }

  DateTime _parseDate(String date) {
    final parts = date.split('/');
    return DateTime(int.parse(parts[1]), int.parse(parts[0]));
  }

  Future<void> _saveEducation() async {
    try {
      final updatedEducation = _education.copyWith(
        degree: _degrees[_selectedDegree.value]
      );
      _formKey.currentState!.save();

      if (_isEditScreen) {
        await _updateEducation(updatedEducation);
      } else {
        await _addEducation(updatedEducation);
      }

      if (mounted) Navigator.pop(context);
    } catch (error) {
      log('Error in education screen: $error');
    }
  }

  Future<void> _addEducation(Education education) {
    return context.read<JobseekerManager>().addEducation(education);
  }

  Future<void> _updateEducation(Education education) {
    return context.read<JobseekerManager>()
        .updateEducation(_educationIndex, education);
  }

  void _showDatePicker({
    required String title,
    required TextEditingController controller,
    required bool isStartDate
  }) {
    showAdditionalScreen(
      context: context,
      title: title,
      child: Builder(
        builder: (context) => MonthPicker(
          centerLeadingDate: true,
          minDate: DateTime(2000, 1),
          maxDate: DateTime.now(),
          onDateSelected: (date) => _handleDateSelection(
            date: date,
            controller: controller,
            isStartDate: isStartDate,
            context: context
          ),
        )
      )
    );
  }

  void _handleDateSelection({
    required DateTime date,
    required TextEditingController controller,
    required bool isStartDate,
    required BuildContext context
  }) {
    final formattedDate = DateFormat("MM/yyyy").format(date);
    final fromDate = isStartDate ? formattedDate : _fromController.text;
    final toDate = isStartDate ? _toController.text : formattedDate;

    if (_isValidDateRange(fromDate, toDate)) {
      controller.text = formattedDate;
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      _showInvalidDateAlert(context);
    }
  }

  void _showInvalidDateAlert(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Không thể chọn ngày',
      text: 'Ngày bắt đầu phải nhỏ hơn ngày kết thúc',
      confirmBtnText: 'Tôi biết rồi',
    );
  }

  void _toggleIsDoing() {
    setState(() {
      _isDoing = !_isDoing;
      _toController.text = _isDoing ? 'Hiện nay' : '';
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _schoolController.dispose();
    _specController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(!_isEditScreen ? 'Thêm học vấn' : 'Chỉnh sửa học vấn'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Trình độ học vấn',
                    style: textTheme.titleMedium!.copyWith(fontSize: 17),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: _selectedDegree,
                  builder: (context, selectedIndex, _) {
                    return SizedBox(
                      width: deviceSize.width,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 3,
                        children: _buildDegreeChips(selectedIndex),
                      ),
                    );
                  }
                ),
                CombinedTextFormField(
                  title: 'Trường',
                  hintText: 'Bắt buộc',
                  keyboardType: TextInputType.text,
                  controller: _schoolController,
                  onSaved: (value) {
                    _education = _education.copyWith(school: value);
                  },
                ),
                const SizedBox(height: 10),
                CombinedTextFormField(
                  title: 'Chuyên ngành',
                  hintText: 'Bắt buộc', 
                  keyboardType: TextInputType.text,
                  controller: _specController,
                  onSaved: (value) {
                    _education = _education.copyWith(specialization: value);
                  }
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: CombinedTextFormField(
                        title: 'Thời điểm bắt đầu',
                        hintText: 'Bắt buộc',
                        keyboardType: TextInputType.text,
                        isRead: true,
                        controller: _fromController,
                        onTap: () => _showDatePicker(
                          title: 'Chọn thời điểm bắt đầu',
                          controller: _fromController,
                          isStartDate: true
                        ),
                        onSaved: (value) => _education = _education.copyWith(startDate: value),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CombinedTextFormField(
                        title: 'Thời điểm kết thúc',
                        hintText: 'Bắt buộc',
                        keyboardType: TextInputType.text,
                        isRead: true,
                        controller: _toController,
                        onTap: () => _showDatePicker(
                          title: 'Chọn thời điểm kết thúc',
                          controller: _toController,
                          isStartDate: false
                        ),
                        isEnable: !_isDoing,
                        onSaved: (value) {
                          _education = _education.copyWith(endDate: value);
                        }
                      ),
                    )
                  ]
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _toggleIsDoing,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Checkbox(
                        value: _isDoing,
                        onChanged: (_) => _toggleIsDoing(),
                      ),
                      Text(
                        'Tôi vẫn đang học',
                        style: theme.textTheme.bodyLarge,
                      )
                    ],
                  ),
                ),
                Align(
                  heightFactor: 3,
                  alignment: Alignment.bottomCenter,
                  child: _buildSaveButton(deviceSize, theme, textTheme),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDegreeChips(int selectedIndex) {
    return List<Widget>.generate(
      _degrees.length,
      (index) => InputChip(
        selected: index == selectedIndex,
        label: Text(
          _degrees[index],
          overflow: TextOverflow.ellipsis,
        ),
        onPressed: () {
          _selectedDegree.value = selectedIndex == index ? -1 : index;
        },
        labelStyle: TextStyle(color: Colors.grey.shade700),
      )
    );
  }

  Widget _buildSaveButton(Size deviceSize, ThemeData theme, TextTheme textTheme) {
    return ValueListenableBuilder<bool>(
      valueListenable: isFull,
      builder: (context, isValid, _) {
        return ValueListenableBuilder<int>(
          valueListenable: _selectedDegree,
          builder: (context, selectedIndex, _) {
            return ElevatedButton(
              onPressed: (isValid && selectedIndex != -1) ? _saveEducation : null,
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
              child: const Text("LƯU"),
            );
          }
        );
      }
    );
  }
}
