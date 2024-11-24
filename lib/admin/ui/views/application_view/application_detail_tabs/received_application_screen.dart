import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/widgets/application_card.dart';
import 'package:job_finder_app/models/application.dart';

class ReceivedApplicationScreen extends StatefulWidget {
  const ReceivedApplicationScreen(
      {super.key,
      required this.parentController,
      required this.isActive,
      required this.receivedApplications});

  final ScrollController parentController;
  final bool isActive;
  final List<Application> receivedApplications;

  @override
  State<ReceivedApplicationScreen> createState() =>
      _ReceivedApplicationScreenState();
}

class _ReceivedApplicationScreenState extends State<ReceivedApplicationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(() {
    //   Utils.logMessage(
    //       'outer scroll position: ${widget.parentController.offset}');
    //   if (widget.parentController.offset <= 270) {
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  //Truyền application vào
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //Hiển thị danh sách tất cả các hồ sơ đã nhận cho bài viết này

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            'Đã nhận: ${widget.receivedApplications.length}',
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: 15,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: widget.receivedApplications.isEmpty
              ? const Center(
                  child: Text('Chưa có ứng viên nào'),
                )
              : ListView.builder(
                  // controller: _scrollController,
                  primary: widget.isActive,
                  itemCount: widget.receivedApplications.length,
                  itemBuilder: (context, index) {
                    //truyền đối tượng application vào
                    final statusIndex =
                        widget.receivedApplications[index].status;
                    final status = statusIndex == 0
                        ? ApplicationState.pending
                        : statusIndex == 1
                            ? ApplicationState.accepted
                            : ApplicationState.rejected;
                    return FractionallySizedBox(
                      widthFactor: 0.94,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ApplicationCard(
                          application: widget.receivedApplications[index],
                          status: status,
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
