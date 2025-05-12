import 'dart:math' as math;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:job_finder_app/ui/employer/widgets/basic_info_card.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/jobseeker_education_card.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/jobseeker_experience_card.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/resume_infor_card.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../../models/jobseeker.dart';
import 'modal_bottom_sheet.dart';

class JobseekerDetailScreen extends StatefulWidget {
  const JobseekerDetailScreen({required this.jobseekerId, super.key});

  final String jobseekerId;

  @override
  State<JobseekerDetailScreen> createState() => _JobseekerDetailScreenState();
}

class _JobseekerDetailScreenState extends State<JobseekerDetailScreen> {
  final _scrollController = ScrollController();
  final _isShowNameTitle = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      _isShowNameTitle.value = _scrollController.offset > 253;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final jobseekerFuture = context.read<ApplicationManager>().getJobseekerById(widget.jobseekerId);

    return Scaffold(
      body: FutureBuilder<Jobseeker?>(
        future: jobseekerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobseeker = snapshot.data;
          if (jobseeker == null) {
            return const Center(child: Text('No data found'));
          }

          return _buildMainContent(context, jobseeker, deviceSize, theme, textTheme);
        }
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, Jobseeker jobseeker, Size deviceSize, ThemeData theme, TextTheme textTheme) {
    return Container(
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
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(jobseeker, theme, textTheme),
          _buildEducationSection(deviceSize, jobseeker),
          const ColorDivider(),
          _buildExperienceSection(deviceSize, jobseeker),
          const ColorDivider(),
          _buildSkillsSection(deviceSize, jobseeker, theme),
          const ColorDivider(),
          _buildResumeSection(deviceSize, jobseeker, context),
          const ColorDivider(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(Jobseeker jobseeker, ThemeData theme, TextTheme textTheme) {
    return SliverAppBar(
      elevation: 0,
      centerTitle: true,
      expandedHeight: 300,
      pinned: true,
      title: ValueListenableBuilder(
        valueListenable: _isShowNameTitle,
        builder: (context, isShow, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 2700),
            child: Text(
              isShow ? '${jobseeker.firstName} ${jobseeker.lastName}' : '',
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderContent(jobseeker, theme, textTheme),
      ),
    );
  }

  Widget _buildHeaderContent(Jobseeker jobseeker, ThemeData theme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(jobseeker, textTheme),
          const SizedBox(height: 10),
          _buildContactInfo(jobseeker, textTheme),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Jobseeker jobseeker, TextTheme textTheme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(jobseeker.getImageUrl()),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${jobseeker.firstName} ${jobseeker.lastName}',
            style: textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(Jobseeker jobseeker, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(Icons.email, jobseeker.email, textTheme, Colors.grey[300]!),
        const SizedBox(height: 10),
        _buildInfoRow(Icons.phone, jobseeker.phone, textTheme, Colors.white),
        const SizedBox(height: 10),
        _buildInfoRow(Icons.location_on, jobseeker.address, textTheme, Colors.white),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, TextTheme textTheme, Color color) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(icon, color: color),
          ),
          const WidgetSpan(child: SizedBox(width: 6)),
          TextSpan(
            text: text,
            style: textTheme.bodyLarge!.copyWith(color: color),
          )
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildEducationSection(Size deviceSize, Jobseeker jobseeker) {
    return SliverToBoxAdapter(
      child: Container(
        width: deviceSize.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BasicInfoCard(
          title: 'Thông tin học vấn',
          children: jobseeker.education.map((edu) => JobseekerEducationCard(edu: edu)).toList(),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildExperienceSection(Size deviceSize, Jobseeker jobseeker) {
    return SliverToBoxAdapter(
      child: Container(
        width: deviceSize.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BasicInfoCard(
          title: 'Kinh nghiệm làm việc',
          children: jobseeker.experience.map((exp) => JobseekerExperienceCard(exp: exp)).toList(),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSkillsSection(Size deviceSize, Jobseeker jobseeker, ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        width: deviceSize.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BasicInfoCard(
          title: 'Kỹ năng',
          children: [
            Wrap(
              spacing: 5,
              children: jobseeker.skills.map((skill) => _buildSkillChip(skill, theme)).toList(),
            )
          ],
        ),
      ),
    );
  }

  InputChip _buildSkillChip(String skill, ThemeData theme) {
    return InputChip(
      label: Text(skill, style: TextStyle(color: theme.primaryColor)),
      elevation: 2,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
        side: BorderSide(color: Colors.grey[400]!),
      ),
      backgroundColor: Colors.blue[200],
      color: WidgetStateColor.resolveWith((state) => Colors.blue[50]!),
      onSelected: (_) {},
    );
  }

  SliverToBoxAdapter _buildResumeSection(Size deviceSize, Jobseeker jobseeker, BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: deviceSize.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BasicInfoCard(
          title: 'CV',
          children: [
            ResumeInforCard(
              resume: jobseeker.resume[0],
              onAction: () => _handleResumeAction(context, jobseeker),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _handleResumeAction(BuildContext context, Jobseeker jobseeker) {
    showAdditionalScreen(
      context: context,
      title: 'Tùy chọn',
      child: Builder(
        builder: (context) => _buildActionButton(
          context: context,
          onDownload: () => _downloadResume(context, jobseeker),
        ),
      ),
      heightFactor: 0.25,
    );
  }

  Future<void> _downloadResume(BuildContext context, Jobseeker jobseeker) async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    if (!context.mounted) return;

    final path = await context.read<ApplicationManager>()
        .downloadFile(jobseeker.resume[0].url, jobseeker.resume[0].fileName);

    if (path != null && context.mounted) {
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: 'Tải xuống thành công',
        text: 'File được tải xuống tại $path',
        confirmBtnText: 'Tôi biết rồi'
      );
    }

    await _showDownloadNotification();
  }

  Future<void> _showDownloadNotification() async {
    final random = math.Random(10).nextInt(1000);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: random,
        channelKey: 'basic_channel',
        actionType: ActionType.Default,
        title: 'Tải xuống thành công',
        body: 'Tại xuống tại thư mục /storage/emulated/0/Download/, nhấn vào để mở',
        payload: {'type': 'download_notification'},
      ),
    );
  }

  ListView _buildActionButton({
    required BuildContext context,
    void Function()? onDownload,
  }) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text(
            'Tải xuống',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: const Icon(Icons.download),
          onTap: onDownload,
        ),
        const Divider(),
      ],
    );
  }
}

class ColorDivider extends StatelessWidget {
  const ColorDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 15,
        decoration: BoxDecoration(
          color: Colors.blue[50],
        ),
      ),
    );
  }
}
