import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:job_finder_app/ui/shared/loading_screen.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';
import 'package:job_finder_app/ui/shared/vietname_provinces.dart';
import 'package:provider/provider.dart';

import '../../shared/utils.dart';

class InformationEditScreen extends StatefulWidget {
  final Jobseeker? jobseeker;

  const InformationEditScreen(this.jobseeker, {super.key});

  @override
  State<InformationEditScreen> createState() => _InformationEditScreenState();
}

class _InformationEditScreenState extends State<InformationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _searchController = TextEditingController();
  final _provinceListenable = ValueNotifier(VietNameProvinces.provinces);
  final _selectedProvinceIndex = ValueNotifier(0);

  File? _imageFile;
  bool _isLoading = false;

  Map<String, String> _userInfo = {
    'firstName': '',
    'lastName': '',
    'phone': '',
    'address': ''
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupSearchListener();
  }

  void _initializeControllers() {
    _firstNameController.text = widget.jobseeker?.firstName ?? '';
    _lastNameController.text = widget.jobseeker?.lastName ?? '';
    _phoneController.text = widget.jobseeker?.phone ?? '';
    _addressController.text = widget.jobseeker?.address ?? '';

    _selectedProvinceIndex.value = _findProvinceIndex();
  }

  int _findProvinceIndex() {
    return _provinceListenable.value.indexWhere((province) {
      final normalizedProvince = Utils.removeVietnameseAccent(province).toLowerCase();
      final normalizedAddress = Utils.removeVietnameseAccent(_addressController.text).toLowerCase();
      return normalizedProvince == normalizedAddress;
    });
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      _provinceListenable.value = VietNameProvinces.searchProvinces(_searchController.text);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (error) {
      log('Error picking image: $error');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      log('Form validation failed');
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() => _isLoading = true);
      
      final jobseekerManager = context.read<JobseekerManager>();
      await jobseekerManager.updateProfile(_userInfo, _imageFile);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      log('Error updating profile: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade600,
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              )
            ],
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: _getProfileImage(),
              fit: BoxFit.cover,
            ),
          ),
        ),
        _buildEditImageButton(),
      ],
    );
  }

  ImageProvider _getProfileImage() {
    if (_imageFile != null) return FileImage(_imageFile!);
    return NetworkImage(widget.jobseeker?.getImageUrl() ?? 
      'https://avatarfiles.alphacoders.com/208/208601.png');
  }

  Widget _buildEditImageButton() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: IconButton(
        icon: Icon(Icons.edit, color: Theme.of(context).indicatorColor),
        onPressed: _pickImage,
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileImage(),
          _buildInputFields(),
          const SizedBox(height: 40),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        CombinedTextFormField(
          title: 'Tên của bạn',
          hintText: 'Bắt buộc',
          keyboardType: TextInputType.name,
          controller: _firstNameController,
          validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập tên' : null,
          onSaved: (value) => _userInfo['firstName'] = value!,
        ),
        const SizedBox(height: 20),
        CombinedTextFormField(
          title: 'Họ của bạn',
          hintText: 'Bắt buộc', 
          keyboardType: TextInputType.name,
          controller: _lastNameController,
          validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập họ' : null,
          onSaved: (value) => _userInfo['lastName'] = value!,
        ),
        const SizedBox(height: 20),
        CombinedTextFormField(
          title: 'Số điện thoại',
          hintText: 'Bắt buộc',
          keyboardType: TextInputType.phone,
          controller: _phoneController,
          validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập số điện thoại' : null,
          onSaved: (value) => _userInfo['phone'] = value!,
        ),
        const SizedBox(height: 20),
        CombinedTextFormField(
          title: 'Địa chỉ',
          hintText: 'Bắt buộc',
          isRead: true,
          keyboardType: TextInputType.streetAddress,
          controller: _addressController,
          onTap: _showProvincesOption,
          validator: (value) => value?.isEmpty ?? true ? 'Vui lòng nhập địa chỉ' : null,
          onSaved: (value) => _userInfo['address'] = value!,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: _updateProfile,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: theme.colorScheme.onPrimary,
          backgroundColor: theme.colorScheme.primary,
          fixedSize: Size(deviceSize.width - 30, 50),
          textStyle: theme.textTheme.titleLarge!.copyWith(
            fontFamily: 'Lato',
            fontSize: 20,
          ),
        ),
        child: const Text('Lưu thay đổi'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: _buildForm(),
            ),
            if (_isLoading) const LoadingScreen(),
          ],
        ),
      ),
    );
  }

  void _showProvincesOption() {
    showAdditionalScreen(
      context: context,
      title: 'Tỉnh/thành phố',
      child: Column(
        children: [
          _buildProvinceSearch(),
          _buildProvinceList(),
        ],
      ),
    );
  }

  Widget _buildProvinceSearch() {
    return TextFormField(
      controller: _searchController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints.tightFor(height: 60),
        labelText: 'Tìm Tỉnh/thành phố',
        prefixIcon: const Icon(Icons.search),
      ),
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildProvinceList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 5),
        child: ValueListenableBuilder<List<String>>(
          valueListenable: _provinceListenable,
          builder: (context, provinces, _) {
            if (provinces.isEmpty) {
              return _buildEmptyProvinceList();
            }
            return _buildProvinceListView(provinces);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyProvinceList() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        'Không tìm thấy địa điểm phù hợp',
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _buildProvinceListView(List<String> provinces) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: provinces.length,
      separatorBuilder: (_, __) => const Divider(thickness: 0.3),
      itemBuilder: (context, index) => _buildProvinceListItem(provinces[index], index),
    );
  }

  Widget _buildProvinceListItem(String province, int index) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedProvinceIndex,
      builder: (context, selectedIndex, _) {
        final isSelected = index == selectedIndex;
        return ListTile(
          selected: isSelected,
          title: Text(
            province,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontFamily: 'Lato',
              color: isSelected ? Theme.of(context).primaryColor : Colors.black,
            ),
          ),
          trailing: isSelected ? Icon(
            Icons.check,
            color: Theme.of(context).primaryColor,
          ) : null,
          onTap: () {
            _addressController.text = province;
            _selectedProvinceIndex.value = index;
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
