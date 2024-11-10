import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/widgets/application_card.dart';
import 'package:job_finder_app/models/application.dart';

class RejectedApplicationScreen extends StatefulWidget {
  const RejectedApplicationScreen({
    super.key,
    required this.parentController,
    required this.isActive,
    required this.rejectedApplications,
  });

  final ScrollController parentController;
  final bool isActive;
  final List<Application> rejectedApplications;

  @override
  State<RejectedApplicationScreen> createState() =>
      _RejectedApplicationScreenState();
}

class _RejectedApplicationScreenState extends State<RejectedApplicationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
            'Đã từ chối: ${widget.rejectedApplications.length}',
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 15,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: widget.rejectedApplications.isEmpty
              ? const Center(
                  child: Text('Chưa có ứng viên nào'),
                )
              : ListView.builder(
                  // controller: _scrollController,
                  itemCount: widget.rejectedApplications.length,
                  primary: widget.isActive,
                  itemBuilder: (context, index) {
                    //truyền đối tượng application vào
                    return FractionallySizedBox(
                      widthFactor: 0.94,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ApplicationCard(
                          application: widget.rejectedApplications[index],
                          status: ApplicationState.rejected,
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
