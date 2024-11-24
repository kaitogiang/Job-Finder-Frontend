import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/jobposting.dart';

class JobpostingGeneralInfo extends StatefulWidget {
  const JobpostingGeneralInfo({super.key, required this.jobposting});

  final Jobposting jobposting;

  @override
  State<JobpostingGeneralInfo> createState() => _JobpostingGeneralInfoState();
}

class _JobpostingGeneralInfoState extends State<JobpostingGeneralInfo> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobposting = widget.jobposting;
    final createdDate =
        DateFormat('dd/MM/yyyy').format(DateTime.parse(jobposting.createdAt));
    final deadline =
        DateFormat('dd/MM/yyyy').format(DateTime.parse(jobposting.deadline));
    final jobtype = jobposting.jobType;
    final contractType = jobposting.contractType;
    final experienceYear = jobposting.experience;
    final level = jobposting.level.join(", ");
    final requiredTech = jobposting.skills.join(", ");
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //hiển thị nhãn ngày đăng, và ngày hết hạn
          Row(
            children: [
              Expanded(
                child: _buildBasicInfo(
                  title: 'Ngày đăng',
                  content: createdDate,
                  icon: Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildBasicInfo(
                  title: 'Ngày hết hạn',
                  content: deadline,
                  icon: Icons.event_available,
                ),
              ),
            ],
          ),
          //hiển thị nhãn loại công việc, và loại hợp đồng
          Row(
            children: [
              Expanded(
                child: _buildBasicInfo(
                    title: 'Loại công việc',
                    content: jobtype,
                    icon: Icons.work_outline),
              ),
              Expanded(
                child: _buildBasicInfo(
                  title: 'Loại hợp đồng',
                  content: contractType,
                  icon: Icons.insert_drive_file,
                ),
              ),
            ],
          ),
          //hiển thị nhãn năm kinh nghiệm tối thiểu và cấp bậc
          Row(
            children: [
              Expanded(
                child: _buildBasicInfo(
                    title: 'Năm kinh nghiệm tối thiểu',
                    content: experienceYear,
                    icon: Icons.military_tech),
              ),
              Expanded(
                child: _buildBasicInfo(
                  title: 'Cấp bậc',
                  content: level,
                  icon: Icons.timeline,
                ),
              ),
            ],
          ),
          _buildBasicInfo(
            title: 'Công nghệ yêu cầu',
            content: requiredTech,
            icon: Icons.code,
          )
        ],
      ),
    );
  }

  ListTile _buildBasicInfo(
      {required String title,
      required String content,
      required IconData icon}) {
    final titleStyle = Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(color: Colors.grey[600]);
    final contentStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        );
    final iconStyle = Theme.of(context).colorScheme.primary;
    return ListTile(
      title: Text(
        title,
        style: titleStyle,
      ),
      subtitle: Text(
        content,
        style: contentStyle,
      ),
      leading: Icon(
        icon,
        color: iconStyle,
      ),
    );
  }
}
