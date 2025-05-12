import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

class ExperienceAdditionScreen extends StatefulWidget {
  final Experience? experience;

  ExperienceAdditionScreen({super.key, this.experience});

  @override
  State<ExperienceAdditionScreen> createState() => _ExperienceAdditionScreenState();
}

class _ExperienceAdditionScreenState extends State<ExperienceAdditionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _roleController = TextEditingController();
  final _companyController = TextEditingController();
  final _isFull = ValueNotifier<bool>(false);

  late final Experience _experience;
  late final bool _isEditScreen;
  late final int _experienceIndex;
  bool _isDoing = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupControllerListeners();
    _populateFields();
  }

  void _initializeData() {
    _experience = widget.experience ?? Experience(role: '', company: '', duration: '');
    _isEditScreen = _isEditMode();
    _experienceIndex = _getExperienceIndex();
    Utils.logMessage('Index is: $_experienceIndex');
  }

  bool _isEditMode() {
    return !(_experience.role.isEmpty && 
            _experience.company.isEmpty && 
            _experience.duration.isEmpty);
  }

  int _getExperienceIndex() {
    if (!_isEditScreen) return -1;
    return context.read<JobseekerManager>()
        .jobseeker.experience.indexOf(_experience);
  }

  void _setupControllerListeners() {
    _roleController.addListener(_validateForm);
    _companyController.addListener(_validateForm);
    _fromController.addListener(_validateForm);
    _toController.addListener(_validateForm);
  }

  void _populateFields() {
    if (_isEditScreen) {
      _roleController.text = _experience.role;
      _companyController.text = _experience.company;
      
      final duration = _experience.duration;
      final index = duration.indexOf('-');
      _fromController.text = duration.substring(0, index - 1);
      _toController.text = duration.substring(index + 1);
      
      _isDoing = duration.contains('Hiện nay');
    }
  }

  void _validateForm() {
    _isFull.value = _roleController.text.isNotEmpty &&
        _companyController.text.isNotEmpty &&
        _fromController.text.isNotEmpty &&
        (_isDoing || _toController.text.isNotEmpty);
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

  Future<void> _saveExperience() async {
    final data = {
      'role': _roleController.text,
      'company': _companyController.text,
      'from': _fromController.text,
      'to': _toController.text
    };

    try {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        text: _isEditScreen ? 'Đang chỉnh sửa kinh nghiệm' : 'Đang thêm kinh nghiệm'
      );

      final manager = context.read<JobseekerManager>();
      if (_isEditScreen) {
        await manager.updateExperience(_experienceIndex, data);
      } else {
        await manager.appendExperience(data);
      }

      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        Navigator.pop(context); // Return to previous screen
      }
    } catch (error) {
      Utils.logMessage('Error in _saveExperience: ${error.toString()}');
    }
  }

  void _showDatePicker(bool isFromDate) {
    final title = isFromDate ? 'Chọn thời điểm bắt đầu' : 'Chọn thời điểm kết thúc';
    
    showAdditionalScreen(
      context: context,
      title: title,
      child: MonthPicker(
        centerLeadingDate: true,
        minDate: DateTime(2020, 1),
        maxDate: DateTime.now(),
        onDateSelected: (value) => _handleDateSelection(value, isFromDate),
      )
    );
  }

  void _handleDateSelection(DateTime value, bool isFromDate) {
    final date = DateFormat("MM/yyyy").format(value);
    final fromDate = isFromDate ? date : _fromController.text;
    final toDate = isFromDate ? _toController.text : date;

    if (_isValidDateRange(fromDate, toDate)) {
      if (isFromDate) {
        _fromController.text = date;
      } else {
        _toController.text = date;
      }
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Không thể chọn ngày',
        text: 'Ngày bắt đầu phải nhỏ hơn ngày kết thúc',
        confirmBtnText: 'Tôi biết rồi',
      );
    }
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
    _roleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(!_isEditScreen ? 'Thêm kinh nghiệm' : 'Chỉnh sửa kinh nghiệm'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CombinedTextFormField(
                title: 'Vị trí',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _roleController,
              ),
              const SizedBox(height: 10),
              CombinedTextFormField(
                title: 'Công ty',
                hintText: 'Bắt buộc', 
                keyboardType: TextInputType.text,
                controller: _companyController,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CombinedTextFormField(
                      title: 'Thời điểm bắt đầu',
                      hintText: 'Bắt buộc',
                      keyboardType: TextInputType.text,
                      isRead: true,
                      controller: _fromController,
                      onTap: () => _showDatePicker(true),
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
                      onTap: () => _showDatePicker(false),
                      isEnable: !_isDoing,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _toggleIsDoing,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isDoing,
                      onChanged: (_) => _toggleIsDoing(),
                    ),
                    Text(
                      'Tôi vẫn đang làm công việc này',
                      style: textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ValueListenableBuilder(
                    valueListenable: _isFull,
                    builder: (context, isValid, _) {
                      return ElevatedButton(
                        onPressed: isValid ? _saveExperience : null,
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
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
