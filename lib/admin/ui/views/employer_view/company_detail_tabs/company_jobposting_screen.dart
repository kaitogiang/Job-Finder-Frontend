import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:job_finder_app/models/company.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/ui/shared/job_card.dart';

class CompanyJobpostingScreen extends StatefulWidget {
  const CompanyJobpostingScreen(
      {super.key, required this.companyJobpostings, required this.company});

  final List<Jobposting>? companyJobpostings;
  final Company? company;
  @override
  State<CompanyJobpostingScreen> createState() =>
      _CompanyJobpostingScreenState();
}

class _CompanyJobpostingScreenState extends State<CompanyJobpostingScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _getTotalCompanyJobpostings() {
    return widget.companyJobpostings!.length;
  }

  int _getTotalActiveJobpostings() {
    DateTime currentDateTime = DateTime.now();
    return widget.companyJobpostings!.where((jobposting) {
      //Chuyển ISO String sang kiểu DateTime
      DateTime jobpostingDeadline = DateTime.parse(jobposting.deadline);
      return jobpostingDeadline.isAfter(currentDateTime);
    }).length;
  }

  int _getTotalExpiredJobpostings() {
    DateTime currentDateTime = DateTime.now();
    return widget.companyJobpostings!.where((jobposting) {
      //Chuyển ISO String sang kiểu DateTime
      DateTime jobpostingDeadline = DateTime.parse(jobposting.deadline);
      return jobpostingDeadline.isBefore(currentDateTime);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //Lấy số lượng bài đăng, bài đăng còn hạn, bài đăng hết hạn
    final totalJobpostings = _getTotalCompanyJobpostings();
    final totalActiveJobpostings = _getTotalActiveJobpostings();
    final totalExpiredJobpostings = _getTotalExpiredJobpostings();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          //Hiện thị thông tin số lượng bài đăng, còn hạn và hết hạn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.comment,
                          color: Colors.blue.shade600,
                        )),
                    const WidgetSpan(child: SizedBox(width: 5)),
                    TextSpan(text: 'Số lượng: $totalJobpostings')
                  ]),
                ),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.schedule,
                          color: Colors.green.shade400,
                        )),
                    const WidgetSpan(child: SizedBox(width: 5)),
                    TextSpan(text: 'Còn hạn: $totalActiveJobpostings')
                  ]),
                ),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.yellow.shade700,
                        )),
                    const WidgetSpan(child: SizedBox(width: 5)),
                    TextSpan(text: 'Hết hạn: $totalExpiredJobpostings')
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          //Hiển thị danh sách các bài đăng
          widget.companyJobpostings!.isEmpty
              ? Expanded(
                  child: Center(
                    child: const Text('Chưa có bài đăng nào'),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: widget.companyJobpostings!.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Transform.scale(
                          scale: 0.97,
                          child: JobCard(
                            widget.companyJobpostings![index],
                            isAdmin: true,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
