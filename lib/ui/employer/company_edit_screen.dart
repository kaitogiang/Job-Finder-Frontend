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
  const CompanyEditScreen(this.company, {Key? key}) : super(key: key);

  final Company company;

  @override
  State<CompanyEditScreen> createState() => _CompanyEditScreenState();
}

class _CompanyEditScreenState extends State<CompanyEditScreen> {
  final ImagePicker _picker = ImagePicker();
  late Company _editedCompany;
  List<Object> imageList = [];
  File? _selectedAvatar;

  // Controllers for various input fields
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
    'address': TextEditingController(),
    'website': TextEditingController(),
    'introduction': TextEditingController(),
    'domain': TextEditingController(),
    'companySize': TextEditingController(),
    'contactName': TextEditingController(),
    'contactRole': TextEditingController(),
    'contactPhone': TextEditingController(),
    'contactEmail': TextEditingController(),
    'employmentPolicy': TextEditingController(),
    'recruitmentPolicy': TextEditingController(),
    'welfarePolicy': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeFields() {
    _editedCompany = widget.company;
    imageList.addAll(widget.company.images);

    // Initialize controllers with existing company data
    _controllers['name']!.text = _editedCompany.companyName;
    _controllers['email']!.text = _editedCompany.companyEmail;
    _controllers['phone']!.text = _editedCompany.companyPhone;
    _controllers['address']!.text = _editedCompany.companyAddress;
    _controllers['website']!.text = _editedCompany.website;
    _controllers['introduction']!.text = _editedCompany.description?['introduction'] ?? '';
    _controllers['domain']!.text = _editedCompany.description?['domain'] ?? '';
    _controllers['companySize']!.text = _editedCompany.description?['companySize'] ?? '';
    _controllers['contactName']!.text = _editedCompany.contactInformation?['fullName'] ?? '';
    _controllers['contactRole']!.text = _editedCompany.contactInformation?['role'] ?? '';
    _controllers['contactPhone']!.text = _editedCompany.contactInformation?['phone'] ?? '';
    _controllers['contactEmail']!.text = _editedCompany.contactInformation?['email'] ?? '';
    _controllers['employmentPolicy']!.text = _editedCompany.policy?['employmentPolicy'] ?? '';
    _controllers['recruitmentPolicy']!.text = _editedCompany.policy?['recruitmentPolicy'] ?? '';
    _controllers['welfarePolicy']!.text = _editedCompany.policy?['welfarePolicy'] ?? '';
  }

  Future<void> _pickImage() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        imageList.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedAvatar = File(image.path);
      });
    }
  }

  Future<void> _saveForm() async {
    if (await _showWarningMessage()) return;

    List<String> modifiedImagesList = [];
    List<File> selectedFiles = [];

    for (var image in imageList) {
      if (image is String) {
        modifiedImagesList.add(image);
      } else {
        selectedFiles.add(image as File);
      }
    }

    _editedCompany = _editedCompany.copyWith(
      companyName: _controllers['name']!.text,
      companyEmail: _controllers['email']!.text,
      companyPhone: _controllers['phone']!.text,
      companyAddress: _controllers['address']!.text,
      website: _controllers['website']!.text,
      images: modifiedImagesList,
      description: {
        'introduction': _controllers['introduction']!.text,
        'domain': _controllers['domain']!.text,
        'companySize': _controllers['companySize']!.text,
      },
      contactInformation: {
        'fullName': _controllers['contactName']!.text,
        'role': _controllers['contactRole']!.text,
        'phone': _controllers['contactPhone']!.text,
        'email': _controllers['contactEmail']!.text,
      },
      policy: {
        'employmentPolicy': _controllers['employmentPolicy']!.text,
        'recruitmentPolicy': _controllers['recruitmentPolicy']!.text,
        'welfarePolicy': _controllers['welfarePolicy']!.text,
      },
    );

    try {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
          title: 'Lưu thông tin',
          text: 'Đang lưu...',
        );

        await context.read<CompanyManager>().updateCompany(_editedCompany, _selectedAvatar, selectedFiles);
        Navigator.of(context, rootNavigator: true).pop();
        
        final isExit = await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Lưu thành công',
          text: 'Đã lưu thông tin thành công, bạn có thể rời khỏi hoặc ở lại',
          showConfirmBtn: true,
          confirmBtnText: 'Đóng',
          onConfirmBtnTap: () => Navigator.of(context, rootNavigator: true).pop(true),
          showCancelBtn: true,
          cancelBtnText: 'Quay lại',
          onCancelBtnTap: () => Navigator.of(context, rootNavigator: true).pop(false),
        ) as bool;

        if (isExit && mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (error) {
      log('Error in company manager: $error');
    }
  }

  Future<bool> _showWarningMessage() async {
    for (var controller in _controllers.values) {
      if (controller.text.isEmpty) {
        return await QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: 'Nhắc nhở',
          text: 'Hãy điền đầy đủ thông tin để có thể giúp việc tuyển dụng dễ dàng hơn',
          showCancelBtn: true,
          cancelBtnText: 'Tiếp tục lưu',
          showConfirmBtn: true,
          confirmBtnText: 'Đồng ý',
          onConfirmBtnTap: () => Navigator.of(context, rootNavigator: true).pop(true),
          onCancelBtnTap: () => Navigator.of(context, rootNavigator: true).pop(false),
        );
      }
    }
    return false;
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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildAvatar(),
              const SizedBox(height: 10),
              _buildBasicInfoCard(),
              const SizedBox(height: 10),
              _buildCompanyDescriptionCard(),
              const SizedBox(height: 10),
              _buildImageUploadCard(baseUrl),
              const SizedBox(height: 10),
              _buildContactInfoCard(),
              const SizedBox(height: 10),
              _buildCompanyPolicyCard(),
              const SizedBox(height: 10),
              _buildSaveButton(deviceSize, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
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
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: _selectedAvatar != null
                    ? FileImage(_selectedAvatar!) as ImageProvider<Object>
                    : NetworkImage(widget.company.imageLink),
                fit: BoxFit.cover,
              ),
            ),
        ),
        CircleAvatar(
          child: IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: _pickAvatar,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard() {
    return UserInfoCard(
      title: 'Thông tin cơ bản',
      children: <Widget>[
        _buildTextFormField('Tên công ty', 'Bắt buộc', TextInputType.name, _controllers['name']!),
        _buildTextFormField('Email', 'Bắt buộc', TextInputType.emailAddress, _controllers['email']!),
        _buildTextFormField('Số điện thoại', 'Bắt buộc', TextInputType.phone, _controllers['phone']!),
        _buildTextFormField('Địa chỉ', 'Bắt buộc', TextInputType.streetAddress, _controllers['address']!),
        _buildTextFormField('Website', 'Bắt buộc', TextInputType.url, _controllers['website']!),
      ],
    );
  }

  Widget _buildCompanyDescriptionCard() {
    return UserInfoCard(
      title: 'Mô tả công ty',
      children: <Widget>[
        _buildTextFormField('Giới thiệu về công ty', 'Tùy chọn', TextInputType.multiline, _controllers['introduction']!, maxLines: 6),
        _buildTextFormField('Ngành nghề kinh doanh', 'Tùy chọn', TextInputType.text, _controllers['domain']!),
        _buildTextFormField('Quy mô công ty', 'Tùy chọn', TextInputType.text, _controllers['companySize']!),
      ],
    );
  }

  Widget _buildImageUploadCard(String? baseUrl) {
    return UserInfoCard(
      title: 'Hình ảnh về công ty',
      children: <Widget>[
        SizedBox(
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
                            setState(() {
                              imageList.removeAt(index);
                            });
                          },
                        )
                      : ImageContainer(
                          url: '',
                          isFileType: true,
                          file: imageList[index] as File,
                          onDelete: () {
                            setState(() {
                              imageList.removeAt(index);
                            });
                          },
                        ),
                  const SizedBox(width: 20),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.grey.shade600,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade600),
              borderRadius: BorderRadius.circular(10),
            ),
            fixedSize: const Size.fromHeight(50),
          ),
          onPressed: _pickImage,
          child: const Text('Thêm hình ảnh', style: TextStyle(fontSize: 17)),
        ),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    return UserInfoCard(
      title: 'Thông tin người liên hệ',
      children: <Widget>[
        _buildTextFormField('Tên người liên hệ chính', 'Tùy chọn', TextInputType.text, _controllers['contactName']!),
        _buildTextFormField('Chức vụ', 'Tùy chọn', TextInputType.text, _controllers['contactRole']!),
        _buildTextFormField('Số điện thoại liên hệ', 'Tùy chọn', TextInputType.phone, _controllers['contactPhone']!),
        _buildTextFormField('Email liên hệ', 'Tùy chọn', TextInputType.emailAddress, _controllers['contactEmail']!),
      ],
    );
  }

  Widget _buildCompanyPolicyCard() {
    return UserInfoCard(
      title: 'Các chính sách công ty',
      children: <Widget>[
        _buildTextFormField('Chính sách tuyển dụng', ' Tùy chọn', TextInputType.multiline, _controllers['recruitmentPolicy']!, maxLines: 6),
        _buildTextFormField('Chính sách làm việc', 'Tùy chọn', TextInputType.multiline, _controllers['employmentPolicy']!, maxLines: 6),
        _buildTextFormField('Chính sách phúc lợi', 'Tùy chọn', TextInputType.multiline, _controllers['welfarePolicy']!, maxLines: 6),
      ],
    );
  }

  Widget _buildTextFormField(String title, String hintText, TextInputType keyboardType, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      children: [
        CombinedTextFormField(
          title: title,
          hintText: hintText,
          keyboardType: keyboardType,
          controller: controller,
          maxLines: maxLines,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSaveButton(Size deviceSize, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: _saveForm,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.primary,
          fixedSize: Size(deviceSize.width - 30, 50),
          textStyle: textTheme.titleLarge!.copyWith(
            fontFamily: 'Lato',
            fontSize: 20,
          ),
        ),
        child: const Text('Lưu thay đổi'),
      ),
    );
  }
}