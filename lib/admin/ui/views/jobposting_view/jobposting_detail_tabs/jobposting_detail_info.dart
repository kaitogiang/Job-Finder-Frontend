import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:job_finder_app/models/jobposting.dart';

class JobpostingDetailInfo extends StatelessWidget {
  const JobpostingDetailInfo({super.key, required this.jobposting});

  final Jobposting jobposting;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: <Widget>[
            //Mô tả công việc
            ContentSection(
              title: 'Mô tả công việc',
              content: jobposting.description,
              isDecorated: true,
            ),
            const SizedBox(
              height: 30,
            ),
            //Yêu cầu công việc
            ContentSection(
              title: 'Yêu cầu công việc',
              content: jobposting.requirements,
              isDecorated: true,
            ),
            const SizedBox(
              height: 30,
            ),
            //Phúc lợi cho ứng viên
            ContentSection(
              title: 'Phức lợi cho ứng viên',
              content: jobposting.benefit,
              isDecorated: true,
            ),
            const SizedBox(
              height: 30,
            ),
            //Địa điểm làm việc
            ContentSection(
              title: 'Địa điểm làm việc',
              content: jobposting.company!.companyAddress,
            ),
            const SizedBox(
              height: 30,
            ),
            //Thông tin liên hệ
            ContentSection(
              title: 'Thông tin liên hệ',
              content:
                  ' ● Người liên hệ: ${jobposting.company?.contactInformation?["fullName"]}\n'
                  ' ● Chức vụ: ${jobposting.company?.contactInformation?["role"]}\n'
                  ' ● Email: ${jobposting.company?.contactInformation?["email"]}\n'
                  ' ● Số điện thoại: ${jobposting.company?.contactInformation?["phone"]}',
            ),
          ],
        ),
      ),
    );
  }
}

//Widget dùng để hổ trợ hiển thị nội dung của QuillEditor
class ContentSection extends StatefulWidget {
  const ContentSection({
    super.key,
    required this.title,
    required this.content,
    this.isDecorated = false,
  });

  final String title;
  final dynamic content;
  final bool isDecorated;

  @override
  State<ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<ContentSection> {
  final _controller = QuillController.basic();

  @override
  void initState() {
    _controller.readOnly = true;
    if (widget.isDecorated) {
      Document document = widget.content as Document;
      _controller.document = Document.fromDelta(document.toDelta());
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.info,
              color: Color.fromRGBO(12, 54, 117, 1),
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              widget.title,
              style: theme.textTheme.titleLarge!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(12, 54, 117, 1),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: !widget.isDecorated
              ? Text(
                  widget.content as String,
                  style: theme.textTheme.bodyLarge,
                  softWrap: true,
                  textAlign: TextAlign.justify,
                )
              : QuillEditor.basic(
                  controller: _controller,
                  configurations: QuillEditorConfigurations(
                    // controller: _controller,
                    showCursor: false,
                  ),
                ),
        ),
      ],
    );
  }
}
