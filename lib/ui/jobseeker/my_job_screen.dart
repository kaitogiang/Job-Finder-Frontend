import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/shared/job_card.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:provider/provider.dart';

class MyJobScreen extends StatelessWidget {
  const MyJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Công việc của tôi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: Container(
              width: deviceSize.width,
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
            bottom: TabBar(
              indicatorColor: theme.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorWeight: 4,
              unselectedLabelColor: const Color.fromRGBO(106, 168, 255, 1),
              labelStyle: textTheme.bodyLarge!.copyWith(
                color: theme.indicatorColor,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
              tabs: const [
                Tab(
                  child: Text(
                    'Đã ứng tuyển',
                  ),
                ),
                Tab(
                  child: Text(
                    'Yêu thích',
                  ),
                )
              ],
            )),
        body: TabBarView(
          children: [
            const SentApplicationScreen(),
            const FavoriteJobpostingScreen(),
          ],
        ),
      ),
    );
  }
}

class FavoriteJobpostingScreen extends StatelessWidget {
  const FavoriteJobpostingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.read<JobpostingManager>().fetchJobposting(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                context.read<JobpostingManager>().fetchJobposting(),
            child: Consumer<JobpostingManager>(
                builder: (context, jobpostingManager, child) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: jobpostingManager.favoriteJob.isNotEmpty
                    ? ListView.builder(
                        itemCount: jobpostingManager.favoriteJob.length,
                        itemBuilder: (context, index) {
                          return JobCard(jobpostingManager.favoriteJob[index]);
                        },
                      )
                    : FractionallySizedBox(
                        widthFactor: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FractionallySizedBox(
                              widthFactor: 0.5,
                              child: Image.asset('assets/images/favorite.png',
                                  color: Colors.blue),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Chưa có việc nào được lưu',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    fontSize: 18,
                                  ),
                            )
                          ],
                        ),
                      ),
              );
            }),
          );
        });
  }
}

class SentApplicationScreen extends StatelessWidget {
  const SentApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            JobStatusCard(
              status: 2,
            ),
            JobStatusCard(
              status: 0,
            ),
            JobStatusCard(
              status: 0,
            ),
            JobStatusCard(
              status: 0,
            ),
            JobStatusCard(
              status: 0,
            ),
            JobStatusCard(
              status: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class JobStatusCard extends StatelessWidget {
  const JobStatusCard({
    super.key,
    required this.status,
  });
  final int status; //0 đã gửi, 1 đã chấp nhận, 2 đã từ chối

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: deviceSize.width,
      child: Card(
        elevation: 3,
        color: status == 0
            ? Colors.blue[50]
            : status == 1
                ? Colors.green[50]
                : Colors.red[50],
        child: Padding(
          padding:
              const EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //? Một dòng để hiển thị ảnh đại diện cùng với tên cty,
              //? Tên vị bài tuyển dụng, fulltime
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //? Hiển thị ảnh đại diện của công ty
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/job_background.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  //? Hiển thị tên công ty, vị trí và loại thời gian
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Senior UI Designer',
                          style: textTheme.titleLarge!.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Công ty TNHH Lego Vĩnh Cữu',
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '100 - 250 Triệu',
                          style: textTheme.bodyLarge!.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              //? Hiển thị nút trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  RecruitmentStatus(
                    status: status,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecruitmentStatus extends StatelessWidget {
  const RecruitmentStatus({
    super.key,
    required this.status,
  });

  final int status; //? 0 là đã gửi, 1 là chấp nhận, 2 là từ chối

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 40,
      width: 130,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: status == 0
            ? Colors.blue[100]
            : status == 1
                ? Colors.green[100]
                : Colors.red[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status == 0
            ? 'Đã gửi'
            : status == 1
                ? 'Chấp nhận'
                : 'Từ chối',
        style: textTheme.bodyLarge!.copyWith(
          color: status == 0
              ? Colors.blue
              : status == 1
                  ? Colors.green[700]
                  : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
