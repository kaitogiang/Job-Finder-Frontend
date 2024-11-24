import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/widgets/application_card.dart';
import 'package:job_finder_app/models/application.dart';

class ApprovedApplicationScreen extends StatefulWidget {
  const ApprovedApplicationScreen({
    super.key,
    required this.parentController,
    required this.isActive,
    required this.approvedApplications,
  });

  final ScrollController parentController;
  final bool isActive;
  final List<Application> approvedApplications;

  @override
  State<ApprovedApplicationScreen> createState() =>
      _ApprovedApplicationScreenState();
}

class _ApprovedApplicationScreenState extends State<ApprovedApplicationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(() {
    //   Utils.logMessage(
    //       'outer scroll position: ${widget.parentController.offset}');
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            'Đã chấp nhận: ${widget.approvedApplications.length}',
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 15,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: widget.approvedApplications.isEmpty
              ? const Center(
                  child: Text('Chưa có ứng viên nào'),
                )
              : ListView.builder(
                  // controller: _scrollController,
                  primary: widget.isActive,
                  itemCount: widget.approvedApplications.length,
                  itemBuilder: (context, index) {
                    //truyền đối tượng application vào
                    return FractionallySizedBox(
                      widthFactor: 0.94,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ApplicationCard(
                          application: widget.approvedApplications[index],
                          status: ApplicationState.accepted,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
