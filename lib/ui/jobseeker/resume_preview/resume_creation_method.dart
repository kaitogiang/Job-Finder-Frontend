import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const PdfColor green = PdfColor.fromInt(0xff4CAF50);
const PdfColor lightGreen = PdfColor.fromInt(0xffcdf1e7);
const PdfColor gray = PdfColor.fromInt(0xFF808080);

const sep = 120.0;

Future<Uint8List> generateResume(PdfPageFormat format, String position,
    Jobseeker jobseeker, List<String> experienceDesc) async {
  final doc = pw.Document(title: 'My Resume', author: 'User');
  //Load ảnh profile từ local vào trong PDF file
  // final profileImage = pw.MemoryImage(
  //   (await rootBundle.load('assets/images/jobseeker.png')).buffer.asUint8List(),
  // );
  //Khởi tạo dữ liệu
  final avatarImage = await networkImage(jobseeker.getImageUrl());
  final experiences = jobseeker.experience;
  final educations = jobseeker.education;
  final skills = jobseeker.skills;

  //Định nghĩa các icon cho thông tin ứng viên
  final locationIcon = pw.Icon(pw.IconData(0xe0c8), color: green);
  final phoneIcon = pw.Icon(pw.IconData(0xe0cd), color: green);
  final emailIcon = pw.Icon(pw.IconData(0xe0be), color: green);

  final pageTheme = await _myPageTheme(format);
  doc.addPage(pw.MultiPage(
      pageTheme: pageTheme,
      build: (pw.Context context) => [
            //widget Partitions dùng để chia chiều rộng trang thành các cột bằng nhau
            pw.Partitions(children: [
              //Cột thứ nhất tính từ trái sang phải
              pw.Partition(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            padding:
                                const pw.EdgeInsets.only(left: 10, bottom: 20),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: <pw.Widget>[
                                //Họ tên của người viết CV
                                pw.Text(
                                  '${jobseeker.firstName} ${jobseeker.lastName}',
                                  textScaleFactor: 2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 7)),
                                //Vị trí ứng tuyển
                                pw.Text(
                                  position,
                                  textScaleFactor: 1.2,
                                  style: pw.Theme.of(context)
                                      .defaultTextStyle
                                      .copyWith(
                                          fontWeight: pw.FontWeight.bold,
                                          color: green),
                                ),
                                //Tạo khoảng trống bên dưới họ tên
                                pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 10)),
                                _basicJobseekerInfo(
                                    info: jobseeker.address,
                                    icon: locationIcon),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 10)),
                                _basicJobseekerInfo(
                                    info: jobseeker.phone, icon: phoneIcon),
                                pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 10)),
                                _basicJobseekerInfo(
                                    info: jobseeker.email, icon: emailIcon),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Container(
                            width: 150,
                            height: 150,
                            decoration: pw.BoxDecoration(
                              borderRadius: pw.BorderRadius.circular(10),
                              image: pw.DecorationImage(image: avatarImage),
                            ),
                          ),
                        ]),
                    //Các phần tiếp theo trong cột thứ nhất
                    //Hiển thị tiêu đề Kinh nghiệm làm việc
                    _Category(title: 'Kinh nghiệm làm việc'),
                    //Hiển thị khối thông tin
                    ...List<_ExperienceBlock>.generate(experiences.length,
                        (index) {
                      return _ExperienceBlock(
                        role: experiences[index].role,
                        company: experiences[index].company,
                        duration: experiences[index].duration,
                        description: experienceDesc[index],
                      );
                    }),
                    //Tạo khoảng trống giữa mục Kinh nghiệm làm việc
                    pw.SizedBox(height: 10),
                    //Tạo tiêu đề học vấn
                    _Category(title: 'Học vấn'),
                    ...List<_EducationBlock>.generate(educations.length,
                        (index) {
                      return _EducationBlock(
                        school: educations[index].school,
                        degree: educations[index].degree,
                        duration:
                            '${educations[index].startDate} - ${educations[index].endDate}',
                        specialization: educations[index].specialization,
                      );
                    }),
                    pw.SizedBox(height: 20),
                    //Hiển thị thông tin kỹ năng
                    _Category(title: 'Kỹ năng'),
                    _SkillBlock(skills: skills),
                  ],
                ),
              ),
            ])
          ]));
  return doc.save();
}

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
  //Load file SVG background
  final bgShape = await rootBundle.loadString('assets/images/resume.svg');
  //Điều chỉnh margin của trang
  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 4.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
  //Định nghĩa theme cho trang
  return pw.PageTheme(
    pageFormat: format, //Định nghĩa orientation và thiết lập layout of PDF page
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.openSansRegular(),
      bold: await PdfGoogleFonts.openSansBold(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Stack(
          children: [
            pw.Positioned(
              child: pw.SvgImage(svg: bgShape),
              left: 0,
              right: 0,
            ),
            pw.Positioned(
              child: pw.Transform.rotate(
                angle: pi,
                child: pw.SvgImage(svg: bgShape),
              ),
              right: 0,
              bottom: 0,
            )
          ],
        ),
      );
    },
  );
}

//Widget dùng để hiển thị phần trăm của cái gì đó
class _Percent extends pw.StatelessWidget {
  _Percent({
    required this.size,
    required this.value,
    required this.title,
  });

  final double size;
  final double value;
  final pw.Widget title;

  static const fontSize = 1.2;

  PdfColor get color => green;

  static const backgroundColor = PdfColors.grey300;

  static const strokeWidth = 5.0;

  @override
  pw.Widget build(pw.Context context) {
    final widgets = <pw.Widget>[
      pw.Container(
        width: size,
        height: size,
        child: pw.Stack(
          alignment: pw.Alignment.center,
          fit: pw.StackFit.expand,
          children: <pw.Widget>[
            pw.Center(
              child: pw.Text(
                '${(value * 100).round().toInt()}%',
                textScaleFactor: fontSize,
              ),
            ),
            pw.CircularProgressIndicator(
              value: value,
              backgroundColor: backgroundColor,
              color: color,
              strokeWidth: strokeWidth,
            )
          ],
        ),
      )
    ];

    widgets.add(title);

    return pw.Column(children: widgets);
  }
}

//Widget dùng để tạo khối thông tin
class _Block extends pw.StatelessWidget {
  _Block({
    required this.title,
    this.icon,
  });

  final String title;

  final pw.IconData? icon;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        //Một dòng để hiển thị tiêu đề của mảnh thông tin và icon
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            //Hiển thị dấu chấm tròn màu xanh trước tiêu đề nội dung
            pw.Container(
                width: 6,
                height: 6,
                margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                decoration: const pw.BoxDecoration(
                  color: green,
                  shape: pw.BoxShape.circle,
                )),
            //Hiển thị tiêu đề của khối thông tin
            pw.Text(
              title,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.bold),
            ),
            //Hiển thị icon ở cuối nếu có thiết lập icon
            pw.Spacer(), //Tạo một khoảng trống chiếm hết phần còn dư của dòng
            if (icon != null) pw.Icon(icon!, color: lightGreen)
          ],
        ),
        //Hiển thị phần mô tả cho nội dung chính
        pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: green, width: 2))),
            padding: const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
            margin: const pw.EdgeInsets.only(left: 5),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Lorem(length: 20),
                ]))
      ],
    );
  }
}

//Widget dùng để tạo kiểu cho các tiêu đề như kinh nghiệm làm việc, học vấn, vvvv
class _Category extends pw.StatelessWidget {
  _Category({required this.title});

  final String title;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
        decoration: const pw.BoxDecoration(
          color: lightGreen,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        margin: const pw.EdgeInsets.only(bottom: 10, top: 20),
        padding: const pw.EdgeInsets.fromLTRB(10, 4, 10, 4),
        child: pw.Text(
          title,
          textScaleFactor: 1.5,
        ));
  }
}

//Wiget dùng để tạo văn bản theo định dạng URL link
class _UrlText extends pw.StatelessWidget {
  _UrlText(this.text, this.url);

  final String text;
  final String url;

  @override
  pw.Widget build(pw.Context context) {
    return pw.UrlLink(
        destination: url,
        child: pw.Text(
          text,
          style: const pw.TextStyle(
            decoration: pw.TextDecoration.underline,
            color: PdfColors.blue,
          ),
        ));
  }
}

class _basicJobseekerInfo extends pw.StatelessWidget {
  _basicJobseekerInfo({required this.info, required this.icon});

  final String info;
  final pw.Icon icon;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: <pw.Widget>[
        icon,
        pw.SizedBox(width: 6),
        pw.Text(
          info,
        ),
      ],
    );
  }
}

//Widget dùng để tạo khối thông tin
class _SkillBlock extends pw.StatelessWidget {
  _SkillBlock({
    required this.skills,
  });

  final List<String> skills;

  @override
  pw.Widget build(pw.Context context) {
    return pw.GridView(
      crossAxisCount: 3,
      childAspectRatio: 0.2,
      children: List<pw.Widget>.generate(skills.length, (index) {
        return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                //Hiển thị dấu chấm tròn màu xanh trước tiêu đề nội dung
                pw.Container(
                    width: 6,
                    height: 6,
                    margin:
                        const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                    decoration: const pw.BoxDecoration(
                      color: green,
                      shape: pw.BoxShape.circle,
                    )),
                //Hiển thị tiêu đề của khối thông tin
                pw.Expanded(
                  child: pw.Text(
                    skills[index],
                    softWrap: true,
                    maxLines: 2,
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(),
                  ),
                ),
                pw.SizedBox(width: 5),
                //Hiển thị icon ở cuối nếu có thiết lập icon
              ],
            ));
      }),
    );
  }
}

class _ExperienceBlock extends pw.StatelessWidget {
  _ExperienceBlock({
    required this.role,
    required this.duration,
    required this.company,
    this.description,
  });

  final String role;
  final String duration;
  final String company;
  final String? description;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        //Một dòng để hiển thị tiêu đề của mảnh thông tin và icon
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            //Hiển thị dấu chấm tròn màu xanh trước tiêu đề nội dung
            pw.Container(
                width: 6,
                height: 6,
                margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                decoration: const pw.BoxDecoration(
                  color: green,
                  shape: pw.BoxShape.circle,
                )),
            //Hiển thị tiêu đề của khối thông tin
            pw.Text(
              role.toUpperCase(),
              style: pw.Theme.of(context).defaultTextStyle.copyWith(
                    fontWeight: pw.FontWeight.bold,
                  ),
            ),
            pw.Spacer(),
            pw.Text(
              duration,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),

        //Hiển thị phần mô tả cho nội dung chính
        pw.Container(
          decoration: const pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(color: green, width: 2))),
          padding: const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
          margin: const pw.EdgeInsets.only(left: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              //Hiển thị thông tin tên công ty
              pw.Row(children: [
                pw.Icon(pw.IconData(0xe0af), color: gray), // Icon công ty
                pw.SizedBox(width: 8),
                pw.Text(
                  company,
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontWeight: pw.FontWeight.normal,
                      ),
                ),
              ]),

              if (description != null) pw.SizedBox(height: 6),
              if (description != null) pw.Text(description!)
            ],
          ),
        )
      ],
    );
  }
}

class _EducationBlock extends pw.StatelessWidget {
  _EducationBlock({
    required this.school,
    required this.duration,
    required this.degree,
    required this.specialization,
  });

  final String school;
  final String duration;
  final String specialization;
  final String degree;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        //Một dòng để hiển thị tiêu đề của mảnh thông tin và icon
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: <pw.Widget>[
            //Hiển thị dấu chấm tròn màu xanh trước tiêu đề nội dung
            pw.Container(
                width: 6,
                height: 6,
                margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                decoration: const pw.BoxDecoration(
                  color: green,
                  shape: pw.BoxShape.circle,
                )),
            //Hiển thị tên trường
            pw.Text(
              school.toUpperCase(),
              style: pw.Theme.of(context).defaultTextStyle.copyWith(
                    fontWeight: pw.FontWeight.bold,
                  ),
            ),
            pw.Spacer(),
            //Thời gian học
            pw.Text(
              duration,
              style: pw.Theme.of(context)
                  .defaultTextStyle
                  .copyWith(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),

        //Hiển thị phần mô tả cho nội dung chính
        pw.Container(
          decoration: const pw.BoxDecoration(
              border: pw.Border(left: pw.BorderSide(color: green, width: 2))),
          padding: const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
          margin: const pw.EdgeInsets.only(left: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              //Hiển thị thông tin tên chuyên ngành đã học
              pw.Row(children: [
                pw.Icon(pw.IconData(0xe30a), color: gray), // Icon máy tính
                pw.SizedBox(width: 8),
                pw.Text(
                  specialization,
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontWeight: pw.FontWeight.normal,
                      ),
                ),
              ]),

              pw.SizedBox(height: 6),
              //Hiển thị thông tin bằng cấp
              pw.Row(children: [
                pw.Icon(pw.IconData(0xe80c), color: gray), // Icon bằng cấp
                pw.SizedBox(width: 8),
                pw.Text(
                  degree,
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontWeight: pw.FontWeight.normal,
                      ),
                ),
              ]),

              pw.SizedBox(height: 6),
              // pw.Lorem(length: 20),
            ],
          ),
        )
      ],
    );
  }
}
