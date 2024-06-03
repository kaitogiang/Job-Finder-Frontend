import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';

class InformationEditScreen extends StatefulWidget {
  const InformationEditScreen({super.key});

  @override
  State<InformationEditScreen> createState() => _InformationEditScreenState();
}

class _InformationEditScreenState extends State<InformationEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? file;
  
  Future<void> _pickFile() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
    } catch(error) {
      log(error.toString());
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
          child: Container(
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
                                  image: file!=null ? FileImage(file!) as ImageProvider<Object>
                                  : NetworkImage(
                                      'https://avatarfiles.alphacoders.com/208/208601.png'),
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
                          onSaved: (value) {},
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Trường nhập họ của người tìm việc
                        CombinedTextFormField(
                          title: 'Họ của bạn',
                          hintText: 'Bắt buộc',
                          keyboardType: TextInputType.name,
                          onSaved: (value) {},
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Trường nhập số điện thoại của người tìm việ
                        CombinedTextFormField(
                          title: 'Số điện thoại',
                          hintText: 'Bắt buộc',
                          keyboardType: TextInputType.phone,
                          onSaved: (value) {},
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CombinedTextFormField(
                          title: 'Địa chỉ',
                          hintText: 'Bắt buộc',
                          keyboardType: TextInputType.streetAddress,
                          onSaved: (value) {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40,),
                //Nút dùng để lưu form lại
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      log('Lưu');
                    },
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
                      textStyle: textTheme.titleLarge!
                          .copyWith(fontFamily: 'Lato', fontSize: 20,),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      );
  }
}
