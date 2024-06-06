import 'dart:developer';

import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class ExperienceAdditionScreen extends StatefulWidget {
  ExperienceAdditionScreen({super.key, Experience? experience}) {
    if (experience == null) {
      exp = Experience(role: '', company: '', duration: '');
    } else {
      exp = experience;
    }
  }

  Experience? exp;

  @override
  State<ExperienceAdditionScreen> createState() =>
      _ExperienceAdditionScreenState();
}

class _ExperienceAdditionScreenState extends State<ExperienceAdditionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _roleController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isDoing = false;
  ValueNotifier<bool> isFull = ValueNotifier(false);

  @override
  void initState() {
    _roleController.addListener(_isValidForm);
    _companyController.addListener(_isValidForm);
    _fromController.addListener(_isValidForm);
    _toController.addListener(_isValidForm);
    super.initState();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _isValidForm() {
    isFull.value = _roleController.text.isNotEmpty &&
        _companyController.text.isNotEmpty &&
        _fromController.text.isNotEmpty &&
        (_isDoing || _toController.text.isNotEmpty);
    log('IsFull la: ${isFull.value}');
  }

  Future<void> _addExperience() async {
    //Lấy dữ liệu từ các trường
    Map<String, String> data = {
      'role': _roleController.text,
      'company': _companyController.text,
      'from': _fromController.text,
      'to': _toController.text
    };
    try {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
          text: 'Đang thêm kinh nghiệm');
      //Gọi API thêm kinh nghiệm
      await context
          .read<JobseekerManager>()
          .appendExperience(data)
          .whenComplete(() => Navigator.pop(context));
      Navigator.pop(context);
    } catch (error) {
      log('Loi trong _addExperienece: exp_addiion_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm kinh nghiệm'),
      ),
      body: Form(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            key: _formKey,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CombinedTextFormField(
                title: 'Vị trí',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _roleController,
              ),
              const SizedBox(
                height: 10,
              ),
              CombinedTextFormField(
                title: 'Công ty',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _companyController,
              ),
              const SizedBox(
                height: 10,
              ),
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
                        onTap: _showFromMonthPicker,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CombinedTextFormField(
                        title: 'Thời điểm kết thúc',
                        hintText: 'Bắt buộc',
                        keyboardType: TextInputType.text,
                        isRead: true,
                        controller: _toController,
                        onTap: _showToMonthPicker,
                        isEnable: !_isDoing,
                      ),
                    )
                  ]),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDoing = !_isDoing;
                    if (_isDoing == true) {
                      _toController.text = 'Hiện nay';
                    } else {
                      _toController.text = '';
                    }
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Checkbox(
                      value: _isDoing,
                      onChanged: (value) {
                        setState(() {
                          _isDoing = !_isDoing;
                          if (_isDoing == true) {
                            _toController.text = 'Hiện nay';
                          } else {
                            _toController.text = '';
                          }
                        });
                      },
                    ),
                    Text(
                      'Tôi vẫn đang làm công việc này',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ValueListenableBuilder(
                      valueListenable: isFull,
                      builder: (context, isValid, child) {
                        return ElevatedButton(
                          onPressed: isValid == false ? null : _addExperience,
                          child: Text("LƯU"),
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
                        );
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showFromMonthPicker() {
    showAdditionalScreen(
        context: context,
        title: 'Chọn thời điểm bắt đầu',
        child: MonthPicker(
          centerLeadingDate: true,
          minDate: DateTime(2020, 1),
          maxDate: DateTime.now(),
          onDateSelected: (value) {
            DateFormat format = DateFormat("MM/yyyy");
            String date = format.format(value);
            _fromController.text = date;
            Navigator.of(context).pop();
          },
        ));
  }

  void _showToMonthPicker() {
    showAdditionalScreen(
        context: context,
        title: 'Chọn thời điểm kết thúc',
        child: MonthPicker(
          centerLeadingDate: true,
          minDate: DateTime(2020, 1),
          maxDate: DateTime.now(),
          onDateSelected: (value) {
            DateFormat format = DateFormat("MM/yyyy");
            String date = format.format(value);
            _toController.text = date;
            Navigator.of(context).pop();
          },
        ));
  }
}
