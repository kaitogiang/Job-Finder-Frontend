import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:job_finder_app/ui/employer/widgets/applicant_card.dart';
import 'package:job_finder_app/ui/shared/enums.dart';
import 'package:provider/provider.dart';

class ApprovedApplicationScreen extends StatelessWidget {
  const ApprovedApplicationScreen({
    super.key,
    required this.applicationStorageId,
  });

  final String applicationStorageId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final textTheme = theme.textTheme;

    final applicationStorage = context
        .watch<ApplicationManager>()
        .getApplicationStorageById(applicationStorageId);

    final approvedApplications = applicationStorage.approvedApplications;
    final jobPosting = applicationStorage.jobposting;
    final deadline =
        DateFormat('dd-MM-yyyy').format(applicationStorage.deadlineDate);

    return Scaffold(
      appBar: _buildAppBar(context, size, theme, textTheme, jobPosting.title,
          deadline, jobPosting),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          shrinkWrap: true,
          children: [
            _buildInfoRow(theme),
            const SizedBox(height: 10),
            approvedApplications.isNotEmpty
                ? _buildApprovedList(approvedApplications)
                : _buildEmptyState(textTheme, size),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    Size size,
    ThemeData theme,
    TextTheme textTheme,
    String jobTitle,
    String deadline,
    dynamic jobPosting,
  ) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Hồ sơ được nhận',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      flexibleSpace: Container(
        width: size.width,
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Card(
            elevation: 5,
            color: theme.indicatorColor,
            child: ListTile(
              leading: Icon(Icons.comment_rounded, color: theme.primaryColor),
              title: Text(
                jobTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.red, size: 18),
                  const SizedBox(width: 7),
                  Text(deadline, style: textTheme.bodyLarge),
                ],
              ),
              trailing: TextButton(
                onPressed: () {
                  context.pushNamed('job-detail', extra: jobPosting);
                },
                child: const Text('Chi tiết'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.info, color: theme.primaryColor),
        const SizedBox(width: 7),
        const Expanded(
          child: Text(
            'Danh sách những ứng viên sẽ được mời phỏng vấn',
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedList(List approvedApplications) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: approvedApplications.length,
      itemBuilder: (context, index) {
        return ApplicantCard(
          application: approvedApplications[index],
          isRead: true,
          status: ApplicationStatus.accepted,
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme, Size size) {
    return SizedBox(
      height: size.height / 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/folder.png', width: 200),
          const SizedBox(height: 10),
          Text('Hiện tại chưa có ứng viên nào', style: textTheme.bodyLarge),
        ],
      ),
    );
  }
}
