import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/locked_jobseeker_tabview/jobseeker_basic_info_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/locked_jobseeker_tabview/jobseeker_locked_status_screen.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/models/locked_users.dart';

class LockedJobseekerDetailScreen extends StatelessWidget {
  const LockedJobseekerDetailScreen(
      {super.key,
      required this.basicInfoFuture,
      required this.lockedInfoFuture});

  final Future<Jobseeker?> basicInfoFuture;
  final Future<LockedUser?> lockedInfoFuture;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 420,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.code),
                  text: 'Thông tin cơ bản',
                ),
                Tab(
                  icon: Icon(Icons.business_center),
                  text: 'Trạng thái khóa',
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  JobseekerBasicInfoScreen(basicInfoFuture: basicInfoFuture),
                  JobseekerLockedStatusScreen(
                      lockedInfoFuture: lockedInfoFuture),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
