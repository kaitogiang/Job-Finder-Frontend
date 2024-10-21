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
  InformationEditScreen(this.jobseeker, {super.key});

  Jobseeker? jobseeker;

  @override
  State<InformationEditScreen> createState() => _InformationEditScreenState();
}

class _InformationEditScreenState extends State<InformationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? file;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final searchController = TextEditingController();
  Map<String, String> userInfo = {
    'firstName': '',
    'lastName': '',
    'phone': '',
    'address': ''
  };
  ValueNotifier<List<String>> provinceListenable =
      ValueNotifier(VietNameProvinces.provinces);
  ValueNotifier<int> selectedProvinceIndex = ValueNotifier(0);
  bool _isLoading = false;

  @override
  void initState() {
    firstNameController.text = widget.jobseeker!.firstName;
    lastNameController.text = widget.jobseeker!.lastName;
    phoneController.text = widget.jobseeker!.phone;
    addressController.text = widget.jobseeker!.address;
    //Tìm chỉ số tỉnh mà trùng với danh sách tỉnh
    int selectedIndex = provinceListenable.value.indexWhere((element) {
      String alteredElement =
          Utils.removeVietnameseAccent(element).toLowerCase();
      String alteredAddress =
          Utils.removeVietnameseAccent(addressController.text).toLowerCase();
      return alteredElement.compareTo(alteredAddress) == 0;
    });
    //Đặt chỉ số được chọn lại
    selectedProvinceIndex.value = selectedIndex;
    searchController.addListener(() {
      String searchText = searchController.text;
      List<String> searchProivinces =
          VietNameProvinces.searchProvinces(searchText);
      provinceListenable.value = searchProivinces;
    });
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          file = File(pickedFile.path);
        });
      }
    } catch (error) {
      log(error.toString());
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      log('Lỗi trong info edit, chưa điền hết');
      return;
    }

    _formKey.currentState!.save();
    log(userInfo.toString());
    try {
      setState(() {
        _isLoading = true;
      });
      final jobseekerManager = context.read<JobseekerManager>();
      await jobseekerManager.updateProfile(userInfo, file);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      log('Lỗi trong infor edit $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
        appBar: AppBar(
          title: Text("Thông tin cá nhân"),
        ),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                width: deviceSize.width,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                //Hiển thị ảnh đại diện trong Container
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
                                      image: file != null
                                          ? FileImage(file!)
                                              as ImageProvider<Object>
                                          : NetworkImage((widget.jobseeker ==
                                                  null)
                                              ? 'https://avatarfiles.alphacoders.com/208/208601.png'
                                              : widget.jobseeker!
                                                  .getImageUrl()),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                //Hiển thị nút chỉnh sửa ảnh
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: theme.indicatorColor,
                                    ),
                                    onPressed: () {
                                      log('Upload ảnh');
                                      _pickFile();
                                    },
                                  ),
                                ),
                                //hiện thị form cho phép chỉnh sửa
                              ],
                            ),
                            //Trường nhập tên của người tìm việc
                            CombinedTextFormField(
                              title: 'Tên của bạn',
                              hintText: 'Bắt buộc',
                              keyboardType: TextInputType.name,
                              controller: firstNameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Vui lòng nhập tên';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                userInfo['firstName'] = value!;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            //Trường nhập họ của người tìm việc
                            CombinedTextFormField(
                              title: 'Họ của bạn',
                              hintText: 'Bắt buộc',
                              keyboardType: TextInputType.name,
                              controller: lastNameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Vui lòng nhập họ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                userInfo['lastName'] = value!;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            //Trường nhập số điện thoại của người tìm việ
                            CombinedTextFormField(
                              title: 'Số điện thoại',
                              hintText: 'Bắt buộc',
                              keyboardType: TextInputType.phone,
                              controller: phoneController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Vui lòng nhập số điện thoại';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                userInfo['phone'] = value!;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            CombinedTextFormField(
                              title: 'Địa chỉ',
                              hintText: 'Bắt buộc',
                              isRead: true,
                              keyboardType: TextInputType.streetAddress,
                              controller: addressController,
                              onTap: _showProvincesOption,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Vui lòng nhập địa chỉ';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                userInfo['address'] = value!;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    //Nút dùng để lưu form lại
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: _updateProfile,
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
                        child: Text('Lưu thay đổi'),
                      ),
                    )
                  ],
                ),
              ),
              if (_isLoading) LoadingScreen(),
            ],
          ),
        ));
  }

  void _showProvincesOption() {
    log('So luong tinh: ${provinceListenable.value.length}');
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
                constraints: BoxConstraints.tight(Size.fromHeight(60)),
                labelText: 'Tìm Tỉnh/thành phố',
                prefixIcon: Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
            ),
            Expanded(
              child: Container(
                  padding: EdgeInsets.only(top: 5),
                  child: ValueListenableBuilder<List<String>>(
                      valueListenable: provinceListenable,
                      builder: (context, provinces, child) {
                        return provinces.isNotEmpty
                            ? ListView.separated(
                                shrinkWrap:
                                    true, //Chỉ định kích thước của ListView bằng với cố lượng phần tử
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
                                            selectedProvinceIndex.value = index;
                                            Navigator.pop(context);
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
