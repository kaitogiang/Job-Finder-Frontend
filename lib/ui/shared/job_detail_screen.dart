import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:job_finder_app/ui/shared/message_manager.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';
import 'package:job_finder_app/ui/shared/resume_selection_screen.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shadow_overlay/shadow_overlay.dart';
import 'package:go_router/go_router.dart';
import '../../models/employer.dart';
import '../auth/auth_manager.dart';
import '../jobseeker/widgets/company_card.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen(this.job, {super.key});

  final Jobposting job;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool isExpanded = false;
  late Jobposting jobposting;

  @override
  void initState() {
    super.initState();
    jobposting = widget.job;
  }

  Future<void> _gotoChatScreen() async {
    //Kiểm tra xem có cuộc trò chuyện nào giữa jobseeker và company này không
    final conversationId = await context
        .read<MessageManager>()
        .verifyExistingConversation(jobposting.company!.id);
    if (conversationId != null) {
      //Truy xuất đến conversation trong danh sách sẳn có
      if (!mounted) return;
      context.pushNamed('chat', extra: conversationId);
    } else {
      //Tạo mới conversation
      if (mounted) {
        String? conversationId = await context
            .read<MessageManager>()
            .createConversation(jobposting.company!.id);
        if (conversationId != null && mounted) {
          context.pushNamed('chat', extra: conversationId);
        }
      } else {
        Utils.logMessage('The widget tree is removed!!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    DateTime deadline = DateTime.parse(jobposting.deadline);
    String formattedDeadline = DateFormat('dd-MM-yyyy').format(deadline);
    DateTime createdDate = DateTime.parse(jobposting.createdAt.split('T')[0]);
    String formattedCreation = DateFormat('dd-MM-yyyy').format(createdDate);
    bool isEmployer = context.read<AuthManager>().isEmployer;
    return Scaffold(
      bottomNavigationBar: isEmployer
          ? null
          : Container(
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
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          fixedSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: theme.primaryColor,
                        ),
                        onPressed: () async {
                          //Kiểm tra xem có thiết lập CV chưa, nếu chưa thì báo lỗi
                          final resumes =
                              context.read<JobseekerManager>().resumes;
                          if (resumes.isEmpty) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: 'Không thể ứng tuyển',
                              text: 'Vui lòng tạo CV trước khi ứng tuyển',
                              confirmBtnText: 'Tôi biết rồi',
                            );
                            return;
                          }
                          //hiển thị modal cho phép chọn CV đã tạo
                          final selection = await showAdditionalScreen(
                            context: context,
                            title: 'Chọn CV của bạn',
                            child: const ResumeSelectionScreen(),
                            heightFactor: 0.7,
                          );
                          //Nếu mở modal ra mà không chọn và đóng lại thì thôi
                          if (selection == null) {
                            return;
                          }
                          final selectedResumeIndex = selection as int;
                          final resumeLink = resumes[selectedResumeIndex].url;
                          Utils.logMessage('CV link nộp: $resumeLink');
                          //Hiển thị xác nhận và gửi CV
                          final isApply = await QuickAlert.show(
                            context: context,
                            type: QuickAlertType.confirm,
                            title:
                                'Bạn có chắc chắn muốn ứng tuyển vào công việc này?',
                            text:
                                'Bạn chỉ được ứng tuyển vào công việc này một lần duy nhất',
                            cancelBtnText: 'Không',
                            confirmBtnText: 'Có',
                            onCancelBtnTap: () =>
                                Navigator.of(context).pop(false),
                            onConfirmBtnTap: () =>
                                Navigator.of(context).pop(true),
                          ) as bool;
                          if (isApply) {
                            log('Apply liền luôn bạn ơi');
                            if (!context.mounted) return;
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.loading,
                                text: 'Đang ứng tuyển');
                            Employer? employer = await context
                                .read<ApplicationManager>()
                                .getEmployerByCompanyId(jobposting.company!.id);
                            if (!context.mounted) return;
                            final result = await context
                                .read<ApplicationManager>()
                                .applyApplication(
                                    jobposting.id, employer!.email, resumeLink);
                            if (result && context.mounted) {
                              //Loại bỏ màn hình loading
                              Navigator.of(context, rootNavigator: true).pop();
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: 'Ứng tuyển thành công',
                                text:
                                    'Bạn đã ứng tuyển vào công việc này, hãy theo dõi thông báo khi có kết quả',
                                confirmBtnText: 'Tôi biết rồi',
                              );
                            } else {
                              if (context.mounted) {
                                //Loại bỏ màn hình đăng nhập
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: 'Ứng tuyển thất bại',
                                  text:
                                      'Bạn không thể ứng tuyển vào vị trí này!',
                                  confirmBtnText: 'Tôi biết rồi',
                                );
                              }
                            }
                          } else {
                            log('Thôi để bữa khác');
                          }
                        },
                        child: Text(
                          'Ứng tuyển ngay',
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 3),
                            ),
                          ]),
                      child: ValueListenableBuilder(
                          valueListenable: jobposting.favorite,
                          builder: (context, isFavorite, child) {
                            return IconButton(
                              onPressed: () async {
                                await context
                                    .read<JobpostingManager>()
                                    .changeFavoriteStatus(jobposting);
                              },
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: theme.primaryColor,
                              ),
                            );
                          }),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 3),
                            ),
                          ]),
                      child: IconButton(
                        onPressed: _gotoChatScreen,
                        icon: Icon(
                          Icons.chat_rounded,
                          color: theme.primaryColor,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
      body: CustomScrollView(
        slivers: <Widget>[
          //? Phần appbar dùng để chứa thông tin giới thiệu về bài tuyển dụng
          SliverAppBar(
            expandedHeight: 400.0,
            floating: false,
            pinned: true,
            toolbarHeight: 80,
            title: Padding(
              padding: const EdgeInsets.only(left: 0, right: 30),
              //? Hiển thị tên công ty ở phần giữa AppBar
              child: Text(
                jobposting.company!.companyName,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge!
                    .copyWith(color: Colors.white, fontSize: 20),
              ),
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // backgroundColor: const Color.fromRGBO(39, 107, 152, 1),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              background: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/company_background.jpg'),
                      fit: BoxFit.cover),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        //? Hiển thị ảnh đại diện của công ty
                        child: Image.network(
                          jobposting.company!.avatarLink,
                          width: 150,
                        ),
                      ),
                      //? Hiển thị tiêu đề của bài tuyển dụng
                      Text(
                        jobposting.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      //? Hiển thị ngày hết hạn ứng tuyển của bài viết
                      Text(
                        'Ngày hết hạn: $formattedDeadline',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                      ),
                      //? Hiển thị vị trí và mức lương
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 70,
                                child: Card(
                                  elevation: 5,
                                  color: Colors.blue[50],
                                  child: ListTile(
                                    visualDensity: VisualDensity.standard,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      child: Icon(
                                        Icons.location_on,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    //? Hiển thị vị trí làm việc của công ty
                                    title: Text(
                                      jobposting.workLocation,
                                      style:
                                          theme.textTheme.bodyLarge!.copyWith(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 70,
                                child: Card(
                                  elevation: 5,
                                  color: Colors.blue[50],
                                  child: ListTile(
                                    visualDensity: VisualDensity.standard,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      child: Icon(
                                        Icons.attach_money_sharp,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    //? Hiển thị mức lương
                                    title: Text(
                                      jobposting.salary,
                                      style:
                                          theme.textTheme.bodyLarge!.copyWith(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          //? Hiển thị phần nội dung chính
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: AnimatedCrossFade(
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
                firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ShadowOverlay(
                        shadowHeight: 100,
                        shadowWidth: deviceSize.width,
                        //? Hiển thị mô tả công việc ở dạng rút gọn
                        child: ContentSection(
                          title: 'Mô tả công việc',
                          content: jobposting.description,
                          isDecorated: true,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            child: const Text(
                              'Xem thêm',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isExpanded = true;
                              });
                            },
                          ),
                        ],
                      )
                    ]),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ContentSection(
                      title: 'Mô tả công việc',
                      content: jobposting.description,
                      isDecorated: true,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // //? Hiển thị yêu cầu công việc
                    ContentSection(
                      title: 'Yêu cầu công việc',
                      content: jobposting.requirements,
                      isDecorated: true,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // //? Hiển thị phúc lợi
                    ContentSection(
                      title: 'Phúc lợi dành cho bạn',
                      content: jobposting.benefit,
                      isDecorated: true,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //? Hiển thị địa điểm làm việc
                    ContentSection(
                      title: 'Địa điểm làm việc',
                      content: jobposting.company!.companyAddress,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ContentSection(
                      title: 'Thông tin liên hệ',
                      content:
                          ' ● Người liên hệ: ${jobposting.company?.contactInformation?["fullName"]}\n'
                          ' ● Chức vụ: ${jobposting.company?.contactInformation?["role"]}\n'
                          ' ● Email: ${jobposting.company?.contactInformation?["email"]}\n'
                          ' ● Số điện thoại: ${jobposting.company?.contactInformation?["phone"]}',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          child: const Text(
                            'Thu bớt',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isExpanded = false;
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          const SectionSeperator(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  //? Hiển thị tiêu đề "Thông tin công ty"
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
                        'Thông tin công ty',
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
                  //todo Hiển thị Card chứa đựng thông tin công ty
                  CompanyCard(
                    company: jobposting.company!,
                  )
                ],
              ),
            ),
          ),
          const SectionSeperator(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  //todo Hiển thị tiêu đề "Thông tin chung"
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
                        'Thông tin chung',
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
                  GeneralInfoRow(
                    title: 'Ngày đăng tuyển',
                    value: formattedCreation,
                  ),
                  const Divider(),
                  GeneralInfoRow(
                    title: 'Ngày hết hạn',
                    value: formattedDeadline,
                  ),
                  const Divider(),
                  GeneralInfoRow(
                    title: 'Trình độ',
                    value: jobposting.level.join(', '),
                  ),
                  const Divider(),
                  GeneralInfoRow(
                    title: 'Loại hợp đồng',
                    value: jobposting.contractType,
                  ),
                  const Divider(),
                  GeneralInfoRow(
                    title: 'Công nghệ yêu cầu',
                    value: jobposting.skills.join(', '),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class GeneralInfoRow extends StatelessWidget {
  const GeneralInfoRow({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionSeperator extends StatelessWidget {
  const SectionSeperator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return SliverToBoxAdapter(
      child: Container(
        width: deviceSize.width,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.blue[50],
        ),
      ),
    );
  }
}

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
                  configurations: QuillEditorConfigurations(
                    controller: _controller,
                    showCursor: false,
                  ),
                ),
        ),
      ],
    );
  }
}
