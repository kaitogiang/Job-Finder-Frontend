import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_finder_app/ui/employer/company_manager.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:job_finder_app/ui/shared/user_info_card.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../../models/company.dart';
import '../shared/image_container.dart';

class CompanyEditScreen extends StatefulWidget {
  const CompanyEditScreen(this.company, {super.key});

  final Company company;

  @override
  State<CompanyEditScreen> createState() => _CompanyEditScreenState();
}

class _CompanyEditScreenState extends State<CompanyEditScreen> {
  final _picker = ImagePicker();
  late Company _editedCompany;
  List<Object> imageList = [];
  //todo danh sách chứa các link ảnh cùng với các File ảnh đã chọn.
  //? Các controllers cho nhóm thông tin cơ bản
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  //? Các controllers cho nhóm mô tả công ty
  final _introductionController = TextEditingController();
  final _domainController = TextEditingController();
  final _companySizeController = TextEditingController();
  //? Các controllers cho nhóm thông tin liên hệ
  final _contactNameController = TextEditingController();
  final _contactRoleController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  //? Các controllers cho nhóm chính sách công ty
  final _recruitmentController = TextEditingController();
  final _employementController = TextEditingController();
  final _welfareController = TextEditingController();

  List<TextEditingController> _allController = [];
  File? _selectedAvatar = null;

  @override
  void initState() {
    //todo Khởi tạo các giá trị ban đầu
    _editedCompany = widget.company;
    imageList.addAll(widget.company.images!);
    //todo Khởi tạo giá trị cho các trường
    _nameController.text = _editedCompany.companyName;
    _emailController.text = _editedCompany.companyEmail;
    _phoneController.text = _editedCompany.companyPhone;
    _addressController.text = _editedCompany.companyAddress;
    _websiteController.text = _editedCompany.website;
    _introductionController.text =
        _editedCompany.description?['introduction'] ?? '';
    _domainController.text = _editedCompany.description?['domain'] ?? '';
    _companySizeController.text =
        _editedCompany.description?['companySize'] ?? '';
    _contactNameController.text =
        _editedCompany.contactInformation?['fullName'] ?? '';
    _contactRoleController.text =
        _editedCompany.contactInformation?['role'] ?? '';
    _contactPhoneController.text =
        _editedCompany.contactInformation?['phone'] ?? '';
    _contactEmailController.text =
        _editedCompany.contactInformation?['email'] ?? '';
    _employementController.text =
        _editedCompany.policy?['employmentPolicy'] ?? '';
    _recruitmentController.text =
        _editedCompany.policy?['recruitmentPolicy'] ?? '';
    _welfareController.text = _editedCompany.policy?['welfarePolicy'] ?? '';
    //todo Gửi tham chiếu vào trong mảng
    _allController.addAll([
      _nameController,
      _emailController,
      _phoneController,
      _addressController,
      _websiteController,
      _introductionController,
      _domainController,
      _companySizeController,
      _contactNameController,
      _contactRoleController,
      _contactPhoneController,
      _contactEmailController,
      _employementController,
      _recruitmentController,
      _welfareController,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    for (TextEditingController controller in _allController) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.length != 0) {
      for (XFile element in images) {
        File file = File(element.path);
        setState(() {
          imageList.add(file);
        });
      }
    }
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      setState(() {
        _selectedAvatar = file;
      });
    }
  }

  Future<void> _saveForm() async {
    //todo kiểm tra xem tất cả trường nếu chưa nhập hết thì hiện thị thông báo nhắc nhở khi nào, vẫn
    //todo muốn lưu dù chưa nhập hết (chọn tiếp tục lưu) thì không làm gì hết, còn nếu chọn quay lại thì return;
    final isCancel = await _showWarningMessage();
    log('Giá trị isCancel: $isCancel');
    if (isCancel) {
      return;
    }
    //todo tạo 2 list rỗng để chứa các ảnh đã chỉnh còn lại và các File ảnh mới
    List<String> modifiedImagesList = []; //? Link ảnh
    List<File> selectedFiles = []; //? File ảnh
    for (Object e in imageList) {
      if (e is String) {
        modifiedImagesList.add(e as String);
      } else {
        selectedFiles.add(e as File);
      }
    }

    //todo Lưu dữ liệu vào bảng
    _editedCompany = _editedCompany.copyWith(
        companyName: _nameController.text,
        companyEmail: _emailController.text,
        companyPhone: _phoneController.text,
        companyAddress: _addressController.text,
        website: _websiteController.text,
        images: modifiedImagesList,
        description: {
          'introduction': _introductionController.text,
          'domain': _domainController.text,
          'companySize': _companySizeController.text,
        },
        contactInformation: {
          'fullName': _contactNameController.text,
          'role': _contactRoleController.text,
          'phone': _contactPhoneController.text,
          'email': _contactEmailController.text,
        },
        policy: {
          'employmentPolicy': _employementController.text,
          'recruitmentPolicy': _recruitmentController.text,
          'welfarePolicy': _welfareController.text
        });

    log('Giá trị của welfarePolicy: ${_editedCompany.toString()}');

    try {
      await context
          .read<CompanyManager>()
          .updateCompany(_editedCompany, _selectedAvatar, selectedFiles);
      //Hiện thị thông báo thành công
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Lưu thành công',
        text: 'Đã lưu thông tin thành công, bạn có thể rời khỏi hoặc ở lại',
        showConfirmBtn: true,
        confirmBtnText: 'Đóng',
        onConfirmBtnTap: () =>
            Navigator.of(context, rootNavigator: true).pop(true),
        showCancelBtn: true,
        cancelBtnText: 'Quay lại',
      );
    } catch (error) {
      log('error in company manager: $error');
    }
  }

  Future<bool> _showWarningMessage() async {
    bool isCancel = false;
    for (TextEditingController element in _allController) {
      if (element.text.isEmpty) {
        isCancel = await QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: 'Nhắc nhở',
          text:
              'Hãy điền đầy đủ thông tin để có thể giúp việc tuyển dụng dễ dàng hơn',
          showCancelBtn: true,
          cancelBtnText: 'Tiếp tục lưu',
          showConfirmBtn: true,
          confirmBtnText: 'Lưu',
          onConfirmBtnTap: () =>
              Navigator.of(context, rootNavigator: true).pop(true),
          onCancelBtnTap: () =>
              Navigator.of(context, rootNavigator: true).pop(false),
        );
        break;
      }
    }
    return isCancel;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    Size deviceSize = MediaQuery.of(context).size;
    String? baseUrl = dotenv.env['DATABASE_BASE_URL'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa công ty',
          style: textTheme.headlineSmall!.copyWith(
            color: theme.indicatorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        width: deviceSize.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.shade600,
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3))
                        ],
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                            image: _selectedAvatar != null
                                ? FileImage(_selectedAvatar!)
                                    as ImageProvider<Object>
                                : NetworkImage(widget.company.imageLink),
                            fit: BoxFit.cover)),
                  ),
                  CircleAvatar(
                    child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: theme.primaryColor,
                      ),
                      onPressed: _pickAvatar,
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              UserInfoCard(
                title: 'Thông tin cơ bản',
                children: <Widget>[
                  CombinedTextFormField(
                    title: 'Tên công ty',
                    hintText: 'Bắt buộc',
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Email',
                    hintText: 'Bắt buộc',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Số điện thoại',
                    hintText: 'Bắt buộc',
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Địa chỉ',
                    hintText: 'Bắt buộc',
                    keyboardType: TextInputType.streetAddress,
                    controller: _addressController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Website',
                    hintText: 'Bắt buộc',
                    keyboardType: TextInputType.emailAddress,
                    controller: _websiteController,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              UserInfoCard(
                title: 'Mô tả công ty',
                children: <Widget>[
                  CombinedTextFormField(
                    title: 'Giới thiệu về công ty',
                    keyboardType: TextInputType.multiline,
                    hintText: 'Tùy chọn',
                    maxLines: 6,
                    minLines: 4,
                    controller: _introductionController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Ngành nghề kinh doanh',
                    keyboardType: TextInputType.text,
                    hintText: 'Tùy chọn',
                    controller: _domainController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Quy mô công ty',
                    keyboardType: TextInputType.text,
                    hintText: 'Tùy chọn',
                    controller: _companySizeController,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              UserInfoCard(
                title: 'Hình ảnh về công ty',
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 130,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: imageList.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            imageList[index] is String
                                ? ImageContainer(
                                    url: '$baseUrl${imageList[index]}',
                                    onDelete: () {
                                      log('Xóa ảnh $index');
                                      setState(() {
                                        imageList.removeAt(index);
                                        log(imageList.toString());
                                      });
                                    },
                                  )
                                : ImageContainer(
                                    url: '',
                                    isFileType: true,
                                    file: imageList[index] as File,
                                    onDelete: () {
                                      log('Xóa file ảnh');
                                      setState(() {
                                        imageList.removeAt(index);
                                      });
                                    },
                                  ),
                            const SizedBox(
                              width: 20,
                            )
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.grey.shade600,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey.shade600),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fixedSize: const Size.fromHeight(50)),
                      onPressed: _pickImage,
                      child: const Text(
                        'Thêm hình ảnh',
                        style: TextStyle(fontSize: 17),
                      ))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              UserInfoCard(
                title: 'Thông tin người liên hệ',
                children: <Widget>[
                  CombinedTextFormField(
                    title: 'Tên người liên hệ chính',
                    hintText: 'Tùy chọn',
                    keyboardType: TextInputType.text,
                    controller: _contactNameController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Chức vụ',
                    hintText: 'Tùy chọn',
                    keyboardType: TextInputType.text,
                    controller: _contactRoleController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Số điện thoại liên hệ',
                    hintText: 'Tùy chọn',
                    keyboardType: TextInputType.phone,
                    controller: _contactPhoneController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Email liên hệ',
                    hintText: 'Tùy chọn',
                    keyboardType: TextInputType.emailAddress,
                    controller: _contactEmailController,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              UserInfoCard(
                title: 'Các chính sách công ty',
                children: <Widget>[
                  CombinedTextFormField(
                    title: 'Chính sách tuyển dụng',
                    keyboardType: TextInputType.multiline,
                    hintText: 'Tùy chọn',
                    maxLines: 6,
                    minLines: 4,
                    controller: _recruitmentController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Chính sách làm việc',
                    keyboardType: TextInputType.multiline,
                    hintText: 'Tùy chọn',
                    maxLines: 6,
                    minLines: 4,
                    controller: _employementController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CombinedTextFormField(
                    title: 'Chính sách phúc lợi',
                    keyboardType: TextInputType.multiline,
                    hintText: 'Tùy chọn',
                    maxLines: 6,
                    minLines: 4,
                    controller: _welfareController,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: _saveForm,
                  child: Text('Lưu thay đổi'),
                  style: ElevatedButton.styleFrom(
                    // side: BorderSide(color: theme.colorScheme.primary),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: theme.colorScheme.onPrimary,
                    backgroundColor: theme.colorScheme.primary,
                    fixedSize: Size(deviceSize.width - 30, 50),
                    textStyle: textTheme.titleLarge!.copyWith(
                      fontFamily: 'Lato',
                      fontSize: 20,
                    ),
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
