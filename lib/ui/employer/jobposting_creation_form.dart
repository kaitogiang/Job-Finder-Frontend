import 'dart:developer';

import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';

import '../shared/modal_bottom_sheet.dart';
import '../shared/utils.dart';
import '../shared/vietname_provinces.dart';

class JobpostingCreationForm extends StatefulWidget {
  const JobpostingCreationForm({super.key});

  @override
  State<JobpostingCreationForm> createState() => _JobpostingCreationFormState();
}

class _JobpostingCreationFormState extends State<JobpostingCreationForm> {
  //? Định nghĩa các controllers cho các trường
  final QuillController _descController = QuillController.basic();
  final QuillController _reqController = QuillController.basic();
  final QuillController _beniController = QuillController.basic();
  final TextEditingController _jobtypeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _workTimeController = TextEditingController();

  ValueNotifier<bool> _isShowDesc = ValueNotifier(false);
  ValueNotifier<bool> _isShowReq = ValueNotifier(false);
  ValueNotifier<bool> _isShowBeni = ValueNotifier(false);

  ValueNotifier<List<String>> _techList = ValueNotifier([]);
  ValueNotifier<List<String>> _levelList = ValueNotifier([]);
  ValueNotifier<String> _selectedJobType = ValueNotifier('');
  ValueNotifier<String> _selectedExperience = ValueNotifier('');
  ValueNotifier<DateTime?> _selectedDeadline = ValueNotifier(null);
  ValueNotifier<bool> _isFullField = ValueNotifier(false);

  FocusNode titleFocus = FocusNode();
  FocusNode workTimeFocus = FocusNode();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  ValueNotifier<List<String>> provinceListenable =
      ValueNotifier(VietNameProvinces.provinces);
  ValueNotifier<int> selectedProvinceIndex = ValueNotifier(0);

  DateTime? selectedTempDate;

  List<String> jobtypeList = [
    "full-time",
    "part-time",
    "internship",
    "contract",
    "temporary",
    "freelance",
    "remote",
    "permanent",
    "project-based",
    "apprenticeship",
    "graduate program",
    "traineeship",
    "shift work",
    "on-call",
    "probationary",
    "volunteer"
  ];

  final List<String> experienceOptions = [
    'Không yêu cầu kinh nghiệm',
    'Dưới 1 năm',
    '1 năm',
    '2 năm',
    '3 năm',
    '4 năm',
    '5 năm',
    'Trên 5 năm',
    'Trên 10 năm'
  ];

  @override
  void initState() {
    _descController.readOnly = true;
    //todo Quan sát người dùng đã nhập dữ liệu vào chưa, nếu chưa nhập thì hiển thị
    //todo TextFormField thường
    _descController.addListener(_descListener);
    //todo Quan sát yêu cầu công việc
    _reqController.readOnly = true;
    _reqController.addListener(_reqListener);
    //todo quan sát lợi ích công việc
    _beniController.readOnly = true;
    _beniController.addListener(_beniListener);
    //todo quan sát các text field
    _titleController.addListener(checkFullField);
    addressController.addListener(checkFullField);
    _workTimeController.addListener(checkFullField);
    _jobtypeController.addListener(checkFullField);
    _experienceController.addListener(checkFullField);

    _selectedDeadline.addListener(checkFullField);
    _selectedJobType.addListener(checkFullField);
    _selectedExperience.addListener(checkFullField);
    _techList.addListener(checkFullField);
    _levelList.addListener(checkFullField);

    //todo Tìm chỉ số tỉnh mà trùng với danh sách tỉnh
    int selectedIndex = provinceListenable.value.indexWhere((element) {
      String alteredElement =
          Utils.removeVietnameseAccent(element).toLowerCase();
      String alteredAddress =
          Utils.removeVietnameseAccent(addressController.text).toLowerCase();
      return alteredElement.compareTo(alteredAddress) == 0;
    });
    //! Nếu không tìm thấy thì chỉ số sẽ là -1 và không có mục nào được chọn
    //todo: Đặt chỉ số được chọn lại
    selectedProvinceIndex.value = selectedIndex;
    searchController.addListener(() {
      String searchText = searchController.text;
      List<String> searchProivinces =
          VietNameProvinces.searchProvinces(searchText);
      provinceListenable.value = searchProivinces;
    });

    super.initState();
  }

  void checkFullField() {
    bool isNotEmptyTitle = _titleController.text.isNotEmpty;
    bool isNotEmptyDesc = !_descController.document.isEmpty();
    bool isNotEmptyReq = !_reqController.document.isEmpty();
    bool isNotEmptyBeni = !_beniController.document.isEmpty();
    bool isNotEmptyTech = _techList.value.isNotEmpty;
    bool isNotEmptyLevel = _levelList.value.isNotEmpty;
    bool isNotEmptyAddress = addressController.text.isNotEmpty;
    bool isNotEmptyWorkTime = _workTimeController.text.isNotEmpty;
    bool isNotEmptyExp = _experienceController.text.isNotEmpty;
    bool isNotEmptyJobType = _jobtypeController.text.isNotEmpty;
    bool isNotEmptyDeadline = _selectedDeadline.value != null;

    if (isNotEmptyTitle &&
        isNotEmptyDesc &&
        isNotEmptyReq &&
        isNotEmptyBeni &&
        isNotEmptyTech &&
        isNotEmptyLevel &&
        isNotEmptyAddress &&
        isNotEmptyWorkTime &&
        isNotEmptyExp &&
        isNotEmptyJobType &&
        isNotEmptyDeadline) {
      _isFullField.value = true;
    } else {
      _isFullField.value = false;
    }
  }

  void _descListener() {
    _isShowDesc.value = !_descController.document.isEmpty();
    checkFullField();
  }

  void _reqListener() {
    _isShowReq.value = !_reqController.document.isEmpty();
    checkFullField();
  }

  void _beniListener() {
    _isShowBeni.value = !_beniController.document.isEmpty();
    checkFullField();
  }

  void _onSavedDesc(Document document) {
    _descController.document = document;
  }

  void _onSavedReq(Document document) {
    _reqController.document = document;
  }

  void _onSavedBeni(Document document) {
    _beniController.document = document;
  }

  Map<String, dynamic> get descParams {
    return {
      'title': 'Mô tả công việc',
      'document': _descController.document,
      'subtitle':
          'Hãy cung cấp thông tin chi tiết và rõ ràng để giúp ứng viên hiểu rõ hơn về công việc',
      'onSaved': _onSavedDesc,
    };
  }

  Map<String, dynamic> get reqParams {
    return {
      'title': 'Yêu cầu công việc',
      'document': _reqController.document,
      'subtitle': 'Hãy nhập vào yêu cầu đầy đủ',
      'onSaved': _onSavedReq,
    };
  }

  Map<String, dynamic> get benifitParams {
    return {
      'title': 'Phúc lợi công việc',
      'document': _beniController.document,
      'subtitle': 'Hãy nhập vào yêu cầu đầy đủ',
      'onSaved': _onSavedBeni,
    };
  }

  void getTechList(List<String> list) {
    _techList.value = list;
  }

  void getLevelList(List<String> list) {
    _levelList.value = list;
  }

  Future<void> _savePost() async {
    String title = _titleController.text;
    String desc = _descController.document.toDelta().toJson().toString();
    String req = _reqController.document.toDelta().toJson().toString();
    String benifit = _beniController.document.toDelta().toJson().toString();
    String tech = _techList.value.join(',');
    String level = _levelList.value.join(',');
    String address = addressController.text;
    String workTime = _workTimeController.text;
    String experience = _experienceController.text;
    String jobType = _jobtypeController.text;
    DateTime? deadline = _selectedDeadline.value;
    log('Title: $title, description: $desc, requirement: $req, benifit: $benifit, technoligy: $tech, level: $level, address: $address, worktime: $workTime, experience: $experience, jobtype: $jobType, address: $address, dealine: $deadline');
  }

  @override
  void dispose() {
    _descController.removeListener(_descListener);
    _reqController.removeListener(_reqListener);
    _descController.dispose();
    _reqController.dispose();

    log('dispose trong JobCreationForm');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final textTheme = theme.textTheme;
    // Lắng nghe thay đổi từ bàn phím
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tạo bài đăng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CombinedTextFormField(
                title: 'Tiêu đề',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _titleController,
                focusNode: titleFocus,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Mô tả công việc',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 5,
              ),

              ValueListenableBuilder(
                  valueListenable: _isShowDesc,
                  builder: (context, isShowDesc, child) {
                    return !isShowDesc
                        ? TextFormField(
                            onTap: () {
                              context.pushNamed('quill-editor',
                                  extra: descParams);
                              titleFocus.unfocus();
                              workTimeFocus.unfocus();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              hintText: 'Nhấp vào để thêm mô tả',
                            ),
                            minLines: 4,
                            maxLines: 4,
                            readOnly: true,
                          )
                        : ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 100,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.black, width: 0.5)),
                              child: Stack(
                                children: [
                                  QuillEditor.basic(
                                    configurations: QuillEditorConfigurations(
                                      controller: _descController,
                                      minHeight: 100,
                                      showCursor: false,
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: GestureDetector(
                                        onTap: () {
                                          context.pushNamed('quill-editor',
                                              extra: descParams);
                                          titleFocus.unfocus();
                                          workTimeFocus.unfocus();
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                  }),
              const SizedBox(
                height: 10,
              ),
              //? Yêu cầu công việc
              Text(
                'Yêu cầu công việc',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              ValueListenableBuilder(
                valueListenable: _isShowReq,
                builder: (context, isShowReq, child) {
                  return !isShowReq
                      ? TextFormField(
                          onTap: () {
                            context.pushNamed('quill-editor', extra: reqParams);
                            titleFocus.unfocus();
                            workTimeFocus.unfocus();
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Nhấp vào để thêm yêu cầu công việc',
                          ),
                          minLines: 4,
                          maxLines: 4,
                          readOnly: true,
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 100,
                            // maxHeight: 300,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.black, width: 0.5)),
                            child: Stack(
                              children: [
                                QuillEditor.basic(
                                  configurations: QuillEditorConfigurations(
                                    controller: _reqController,
                                    minHeight: 100,
                                    showCursor: false,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: GestureDetector(
                                      onTap: () {
                                        context.pushNamed('quill-editor',
                                            extra: reqParams);
                                        titleFocus.unfocus();
                                        workTimeFocus.unfocus();
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              //? Phúc lợi công việc
              Text(
                'Phúc lợi công việc',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              ValueListenableBuilder(
                valueListenable: _isShowBeni,
                builder: (context, isShowBeni, child) {
                  return !isShowBeni
                      ? TextFormField(
                          onTap: () {
                            context.pushNamed('quill-editor',
                                extra: benifitParams);
                            titleFocus.unfocus();
                            workTimeFocus.unfocus();
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: 'Nhấp vào để thêm phúc lợi công việc',
                          ),
                          minLines: 4,
                          maxLines: 4,
                          readOnly: true,
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 100,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.black, width: 0.5)),
                            child: Stack(
                              children: [
                                QuillEditor.basic(
                                  configurations: QuillEditorConfigurations(
                                    controller: _beniController,
                                    minHeight: 100,
                                    showCursor: false,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: GestureDetector(
                                      onTap: () {
                                        context.pushNamed('quill-editor',
                                            extra: benifitParams);
                                        titleFocus.unfocus();
                                        workTimeFocus.unfocus();
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                },
              ),
              //? Công nghệ yêu cầu
              Text(
                'Công nghệ yêu cầu',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 70,
                ),
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                alignment: Alignment.centerLeft,
                width: deviceSize.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 0.5),
                ),
                child: ValueListenableBuilder(
                    valueListenable: _techList,
                    builder: (context, techList, child) {
                      bool isEmptyList = techList.isEmpty;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isEmptyList)
                              Wrap(
                                direction: Axis.horizontal,
                                spacing: 10,
                                children: List<Widget>.generate(techList.length,
                                    (index) {
                                  return InputChip(
                                    label: Text(
                                      techList[index],
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      side: BorderSide(
                                        color: Colors.grey[400]!,
                                      ),
                                    ),
                                    backgroundColor: Colors.blue[200],
                                    color:
                                        WidgetStateColor.resolveWith((state) {
                                      return Colors.blue[50]!;
                                    }),
                                    onSelected: (value) {},
                                  );
                                }),
                              ),
                            if (!isEmptyList) const Divider(),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 1,
                                backgroundColor: theme.indicatorColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: BorderSide(
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Map<String, dynamic> data = {
                                  'onSaved': getTechList,
                                  'techList': techList,
                                };
                                context.pushNamed('tech-addition', extra: data);
                                titleFocus.unfocus();
                                workTimeFocus.unfocus();
                              },
                              label: Text(isEmptyList ? 'Thêm' : 'Chỉnh sửa'),
                              icon: Icon(
                                  isEmptyList ? Icons.add_circle : Icons.edit),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              //? Trình độ
              Text(
                'Trình độ',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 70,
                ),
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                alignment: Alignment.centerLeft,
                width: deviceSize.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 0.5),
                ),
                child: ValueListenableBuilder(
                    valueListenable: _levelList,
                    builder: (context, levelList, child) {
                      bool isEmptyList = levelList.isEmpty;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isEmptyList)
                              Wrap(
                                direction: Axis.horizontal,
                                spacing: 10,
                                children: List<Widget>.generate(
                                    levelList.length, (index) {
                                  return InputChip(
                                    label: Text(
                                      levelList[index],
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    elevation: 2,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      side: BorderSide(
                                        color: Colors.grey[400]!,
                                      ),
                                    ),
                                    backgroundColor: Colors.blue[200],
                                    color:
                                        WidgetStateColor.resolveWith((state) {
                                      return Colors.blue[50]!;
                                    }),
                                    onSelected: (value) {},
                                  );
                                }),
                              ),
                            if (!isEmptyList) const Divider(),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 1,
                                backgroundColor: theme.indicatorColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: BorderSide(
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Map<String, dynamic> data = {
                                  'level': levelList,
                                  'onSaved': getLevelList,
                                };
                                context.pushNamed('level-addition',
                                    extra: data);
                                titleFocus.unfocus();
                                workTimeFocus.unfocus();
                              },
                              label: Text(isEmptyList ? 'Thêm' : 'Chỉnh sữa'),
                              icon: Icon(
                                  isEmptyList ? Icons.add_circle : Icons.edit),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              //? Thành phố nơi làm việc
              CombinedTextFormField(
                title: 'Tỉnh/thành phố làm việc',
                hintText: 'Chọn nơi làm việc',
                keyboardType: TextInputType.text,
                isRead: true,
                controller: addressController,
                onTap: _showProvincesOption,
              ),
              const SizedBox(
                height: 10,
              ),
              CombinedTextFormField(
                title: 'Thời gian làm việc',
                hintText: 'Nhập vào thời gian làm việc',
                keyboardType: TextInputType.text,
                controller: _workTimeController,
                focusNode: workTimeFocus,
              ),
              const SizedBox(
                height: 10,
              ),
              //? Loại công việc
              Text(
                'Loại công việc',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              DropdownMenu<String>(
                initialSelection: jobtypeList[0],
                controller: _jobtypeController,
                requestFocusOnTap: false,
                // enableSearch: false,
                // enableFilter: true,
                onSelected: (value) {
                  _selectedJobType.value = value!;
                  titleFocus.unfocus();
                  workTimeFocus.unfocus();
                },
                inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
                dropdownMenuEntries:
                    jobtypeList.map<DropdownMenuEntry<String>>((value) {
                  return DropdownMenuEntry<String>(
                    value: value,
                    label: value,
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 10,
              ),
              //? SỐ năm kinh nghiệm ít nhất
              Text(
                'Kinh nghiệm tối thiểu',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              DropdownMenu<String>(
                initialSelection: experienceOptions[0],
                controller: _experienceController,
                requestFocusOnTap: false,
                // enableSearch: false,
                // enableFilter: true,

                onSelected: (value) {
                  _selectedExperience.value = value!;
                  titleFocus.unfocus();
                  workTimeFocus.unfocus();
                },
                width: 280,
                inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                )),
                dropdownMenuEntries:
                    experienceOptions.map<DropdownMenuEntry<String>>((value) {
                  return DropdownMenuEntry<String>(
                    value: value,
                    label: value,
                  );
                }).toList(),
              ),
              //? Hạn chót nộp hồ sơ
              Text(
                'Hạn chót ứng tuyển',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 70,
                ),
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                alignment: Alignment.centerLeft,
                width: deviceSize.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: ValueListenableBuilder(
                      valueListenable: _selectedDeadline,
                      builder: (context, selectedDeadline, child) {
                        String deadline = '';
                        if (selectedDeadline != null) {
                          deadline =
                              DateFormat('dd-MM-yyyy').format(selectedDeadline);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (selectedDeadline != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    deadline,
                                    style: textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            if (selectedDeadline != null) const Divider(),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 1,
                                backgroundColor: theme.indicatorColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: BorderSide(
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                titleFocus.unfocus();
                                workTimeFocus.unfocus();
                                await showAdditionalScreen(
                                  context: context,
                                  title: 'Hạn chót ứng tuyển',
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: DatePicker(
                                          minDate: DateTime.now(),
                                          maxDate: DateTime.now()
                                              .add(const Duration(days: 200)),
                                          onDateSelected: (value) {
                                            // Handle selected date
                                            selectedTempDate = value;
                                          },
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 3,
                                          fixedSize: const Size.fromHeight(50),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          backgroundColor: theme.primaryColor,
                                        ),
                                        onPressed: () {
                                          if (selectedTempDate != null) {
                                            _selectedDeadline.value =
                                                selectedTempDate;
                                            checkFullField();
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          }
                                        },
                                        child: Text(
                                          'Chọn ngày',
                                          style: theme.textTheme.titleMedium!
                                              .copyWith(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              label: const Text('Thiết lập'),
                              icon: const Icon(Icons.add_circle),
                            ),
                          ],
                        );
                      }),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : 0),
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: 70,
          width: deviceSize.width,
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
              color: Colors.grey.shade600,
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: ValueListenableBuilder(
                      valueListenable: _isFullField,
                      builder: (context, isFull, child) {
                        log('kq cua isFull: $isFull');
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            fixedSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: theme.primaryColor,
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          onPressed: !isFull ? null : _savePost,
                          child: Text(
                            'Đăng bài',
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontSize: 18,
                              color: !isFull ? Colors.grey : Colors.white,
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProvincesOption() {
    log('So luong tinh: ${provinceListenable.value.length}');
    //todo Tìm chỉ số tỉnh mà trùng với danh sách tỉnh
    int selectedIndex = provinceListenable.value.indexWhere((element) {
      String alteredElement =
          Utils.removeVietnameseAccent(element).toLowerCase();
      String alteredAddress =
          Utils.removeVietnameseAccent(addressController.text).toLowerCase();
      return alteredElement.compareTo(alteredAddress) == 0;
    });
    //! Nếu không tìm thấy thì chỉ số sẽ là -1 và không có mục nào được chọn
    //todo: Đặt chỉ số được chọn lại
    selectedProvinceIndex.value = selectedIndex;
    showAdditionalScreen(
        context: context,
        title: 'Tỉnh/thành phố',
        child: Column(
          children: [
            TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints.tight(const Size.fromHeight(60)),
                labelText: 'Tìm Tỉnh/thành phố',
                prefixIcon: const Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
            ),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: ValueListenableBuilder<List<String>>(
                      valueListenable: provinceListenable,
                      builder: (context, provinces, child) {
                        return !provinces.isEmpty
                            ? ListView.separated(
                                shrinkWrap:
                                    true, //TODO: Chỉ định kích thước của ListView bằng với cố lượng phần tử
                                itemCount: provinces.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(
                                          thickness: 0.3,
                                        ),
                                itemBuilder: (context, index) {
                                  return ValueListenableBuilder<int>(
                                      valueListenable: selectedProvinceIndex,
                                      builder: (context, provinceIndex, child) {
                                        return ListTile(
                                          selected: index == provinceIndex,
                                          title: Text(
                                            provinces[index],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    fontFamily: 'Lato',
                                                    color:
                                                        index == provinceIndex
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Colors.black),
                                          ),
                                          trailing: index == provinceIndex
                                              ? Icon(
                                                  Icons.check,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )
                                              : null,
                                          onTap: () {
                                            log('Đã chọn ${provinces[index]}');
                                            addressController.text =
                                                provinces[index];
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          },
                                        );
                                      });
                                })
                            : Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'Không tìm thấy địa điểm phù hợp',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: 17,
                                      ),
                                ),
                              );
                      })),
            )
          ],
        ));
  }
}
