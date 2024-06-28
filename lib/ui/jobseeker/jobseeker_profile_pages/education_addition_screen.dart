import 'dart:developer';

import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../../shared/addition_data.dart';

class EducationAdditionScreen extends StatefulWidget {
  EducationAdditionScreen({super.key, Education? education}) {
    if (education == null) {
      edu = Education(
          specialization: '',
          school: '',
          degree: '',
          startDate: '',
          endDate: '');
    } else {
      edu = education;
    }
  }

  Education? edu;

  @override
  State<EducationAdditionScreen> createState() =>
      _EducationAdditionScreenState();
}

class _EducationAdditionScreenState extends State<EducationAdditionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _schoolController = TextEditingController();
  final _specController = TextEditingController();
  List<String> degrees = List<String>.from(getDegree());
  bool _isDoing = false;
  ValueNotifier<bool> isFull = ValueNotifier(false);
  ValueNotifier<int> _selectedDegree = ValueNotifier(-1);
  bool isEditScreen = true;
  int eduIndx = -1;

  @override
  void initState() {
    if (widget.edu!.degree.isEmpty &&
        widget.edu!.school.isEmpty &&
        widget.edu!.specialization.isEmpty &&
        widget.edu!.startDate.isEmpty &&
        widget.edu!.endDate.isEmpty) {
      isEditScreen = false;
    } else {
      eduIndx = context
          .read<JobseekerManager>()
          .jobseeker
          .education
          .indexOf(widget.edu!);
    }
    log('Index la: $eduIndx');

    _schoolController.addListener(_isValidForm);
    _specController.addListener(_isValidForm);
    _fromController.addListener(_isValidForm);
    _toController.addListener(_isValidForm);
    //Khởi tạo giá trị cho các trường
    if (widget.edu != null) {
      _schoolController.text = widget.edu!.school;
      _specController.text = widget.edu!.specialization;
      _fromController.text = widget.edu!.startDate;
      _toController.text = widget.edu!.endDate;
      _selectedDegree.value = degrees.indexOf(widget.edu!.degree);
      _isDoing = widget.edu!.endDate == 'Hiện nay';
    }
    super.initState();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _isValidForm() {
    isFull.value = _schoolController.text.isNotEmpty &&
        _specController.text.isNotEmpty &&
        _fromController.text.isNotEmpty &&
        (_toController.text.isNotEmpty);
    log('IsFull la: ${isFull.value}');
    log('End start: ${_toController.text}');
    log('School la: ${_schoolController.text}');
    log('Spec la: ${_specController.text}');
    log('From la: ${_fromController.text}');
    log('Degree la: ${_selectedDegree}');
  }

  Future<void> _addEducation() async {
    try {
      //Gán các giá trị
      widget.edu = widget.edu!.copyWith(degree: degrees[_selectedDegree.value]);
      _formKey.currentState!.save();
      //todo lưu một lượt nhiều trường
      log(widget.edu.toString());
      //Gọi API thêm kinh nghiệm
      await context
          .read<JobseekerManager>()
          .addEducation(widget.edu!)
          .whenComplete(() => Navigator.pop(context));
    } catch (error) {
      log('Loi trong education: edu screen ${error}');
    }
  }

  Future<void> _updateEducation() async {
    try {
      //Gán các giá trị
      widget.edu = widget.edu!.copyWith(degree: degrees[_selectedDegree.value]);
      _formKey.currentState!.save();
      //todo lưu một lượt nhiều trường
      log(widget.edu.toString());
      //Gọi API thêm kinh nghiệm
      await context
          .read<JobseekerManager>()
          .updateEducation(eduIndx, widget.edu!)
          .whenComplete(() => Navigator.pop(context));
    } catch (error) {
      log('Loi trong education: edu screen ${error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(!isEditScreen ? 'Thêm học vấn' : 'Chỉnh sửa học vấn'),
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
                    builder: (context, selectedIndex, child) {
                      return Container(
                        width: deviceSize.width,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 3,
                          children:
                              List<Widget>.generate(degrees.length, (index) {
                            return InputChip(
                              selected: index == selectedIndex,
                              label: Text(
                                degrees[index],
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: () {
                                //TODO nếu chip chưa được chọn, tức là _selectedDegree != index của chip
                                //TODO thì sẽ thực thi lệnh else. Ngược lại nếu chip đã được chọn
                                //TODO mà người dùng chọn lần nữa thì hủy chip đó bằng cách set giá trị = -1
                                if (selectedIndex == index) {
                                  _selectedDegree.value = -1;
                                } else {
                                  _selectedDegree.value = index;
                                }
                              },
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade700),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                CombinedTextFormField(
                  title: 'Trường',
                  hintText: 'Bắt buộc',
                  keyboardType: TextInputType.text,
                  controller: _schoolController,
                  onSaved: (value) {
                    widget.edu = widget.edu!.copyWith(school: value);
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CombinedTextFormField(
                    title: 'Chuyên ngành',
                    hintText: 'Bắt buộc',
                    keyboardType: TextInputType.text,
                    controller: _specController,
                    onSaved: (value) {
                      widget.edu = widget.edu!.copyWith(specialization: value);
                    }),
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
                          onSaved: (value) => widget.edu =
                              widget.edu!.copyWith(startDate: value),
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
                            onSaved: (value) {
                              widget.edu = widget.edu!.copyWith(endDate: value);
                            }),
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
                        'Tôi vẫn đang học',
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    ],
                  ),
                ),
                Align(
                  heightFactor: 3,
                  alignment: Alignment.bottomCenter,
                  child: ValueListenableBuilder<bool>(
                      valueListenable: isFull,
                      builder: (context, isValid, child) {
                        return ValueListenableBuilder<int>(
                            valueListenable: _selectedDegree,
                            builder: (context, selectedIndex, child) {
                              log('Chi so đã chọn: $selectedIndex');
                              return ElevatedButton(
                                onPressed:
                                    (isValid == false || selectedIndex == -1)
                                        ? null
                                        : (!isEditScreen)
                                            ? _addEducation
                                            : _updateEducation,
                                child: Text("LƯU"),
                                style: ElevatedButton.styleFrom(
                                    disabledBackgroundColor:
                                        Colors.grey.shade300,
                                    fixedSize: Size(deviceSize.width, 60),
                                    backgroundColor: theme.primaryColor,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    textStyle: textTheme.titleMedium),
                              );
                            });
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFromMonthPicker() {
    showAdditionalScreen(
        context: context,
        title: 'Chọn thời điểm bắt đầu',
        child: Builder(builder: (context) {
          return MonthPicker(
            centerLeadingDate: true,
            minDate: DateTime(2020, 1),
            maxDate: DateTime.now(),
            onDateSelected: (value) {
              DateFormat format = DateFormat("MM/yyyy");
              String date = format.format(value);
              _fromController.text = date;
              Navigator.of(context).pop();
            },
          );
        }));
  }

  void _showToMonthPicker() {
    showAdditionalScreen(
        context: context,
        title: 'Chọn thời điểm kết thúc',
        child: Builder(builder: (context) {
          return MonthPicker(
            centerLeadingDate: true,
            minDate: DateTime(2020, 1),
            maxDate: DateTime.now(),
            onDateSelected: (value) {
              DateFormat format = DateFormat("MM/yyyy");
              String date = format.format(value);
              _toController.text = date;
              Navigator.of(context).pop();
            },
          );
        }));
  }
}
