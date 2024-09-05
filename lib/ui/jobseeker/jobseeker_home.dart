import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/job_page_view.dart';
import 'package:job_finder_app/ui/shared/job_card.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:job_finder_app/ui/shared/loading_screen.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:provider/provider.dart';

import 'widgets/home_card.dart';
import 'widgets/search_field.dart';

class JobseekerHome extends StatefulWidget {
  const JobseekerHome({super.key});

  @override
  State<JobseekerHome> createState() => _JobseekerHomeState();
}

class _JobseekerHomeState extends State<JobseekerHome> {
  ScrollController? _scrollController;
  final double _scrollThreshold = 170;
  final ValueNotifier<bool> _isShowSearchAppbar = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    Utils.logMessage("Jobseeker home init state");
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      if (_scrollController!.offset >= _scrollThreshold) {
        _isShowSearchAppbar.value = true;
      } else {
        _isShowSearchAppbar.value = false;
      }
    });

    //Lắng nghe jobposting socket
    context.read<JobpostingManager>().listenToJobpostingChanges();
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    List<String> levelList = [
      'Tất cả',
      'Intern',
      'Fresher',
      'Junior',
      'Middle',
      'Senior',
      'Trưởng phòng',
      'Trưởng nhóm'
    ];

    List<FilterType> filteredList = [
      FilterType.all,
      FilterType.intern,
      FilterType.fresher,
      FilterType.junior,
      FilterType.middle,
      FilterType.senior,
      FilterType.manager,
      FilterType.leader,
    ];

    final ValueNotifier<int> _selectedLevelIndex = ValueNotifier(0);
    // String userName = context.read<JobseekerManager>().jobseeker.firstName;
    String userName = '';

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/job_logo.png'),
              )),
          title: ValueListenableBuilder(
              valueListenable: _isShowSearchAppbar,
              builder: (context, isShowSearch, child) {
                return !isShowSearch ? Text('Xin chào') : SearchField();
              }),
          toolbarHeight: 70,
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
                  ]),
            ),
          ),
        ),
        body: FutureBuilder(
            future: context.read<JobpostingManager>().fetchJobposting(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<JobpostingManager>().fetchJobposting(),
                child: Container(
                  decoration: BoxDecoration(color: Colors.blue[50]),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Consumer<JobpostingManager>(
                        builder: (context, jobpostingManager, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            width: deviceSize.width,
                            height: 200,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.blueAccent.shade700,
                                      Colors.blueAccent.shade400,
                                      theme.primaryColor,
                                    ]),
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FractionallySizedBox(
                                  widthFactor: 0.8,
                                  child: Text(
                                    'Bạn đã tìm thấy công việc yêu thích chưa?',
                                    style: textTheme.titleLarge!
                                        .copyWith(color: theme.indicatorColor),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SearchField()
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          //? Build mục chọn cấp độ công việc
                          HomeCard(
                            title: 'Cấp độ của bạn',
                            child: ValueListenableBuilder(
                                valueListenable: _selectedLevelIndex,
                                builder: (context, selectedIndex, child) {
                                  return Wrap(
                                    spacing: 10,
                                    children: List<InputChip>.generate(
                                        levelList.length, (index) {
                                      return InputChip(
                                        label: Text(
                                          levelList[index],
                                          style: TextStyle(
                                              color: index == selectedIndex
                                                  ? Colors.white
                                                  : Colors.grey),
                                        ),
                                        selected: index == selectedIndex,
                                        elevation: 2,
                                        checkmarkColor: Colors.white,
                                        selectedColor: Colors.blue[700],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40)),
                                        onSelected: (value) {
                                          _selectedLevelIndex.value = index;
                                          context
                                              .read<JobpostingManager>()
                                              .filterJobposting(
                                                  filteredList[index]);
                                        },
                                      );
                                    }),
                                  );
                                }),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          //? Build mục công việc gợi ý
                          HomeCard(
                            title: 'Gợi ý hôm nay',
                            child:
                                JobPageView(jobpostingManager.randomJobposting),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Tất cả việc làm (${jobpostingManager.filteredPosts.length})',
                              style: textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 22),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          jobpostingManager.filteredPosts.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: ListView.builder(
                                    itemCount:
                                        jobpostingManager.filteredPosts.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return JobCard(jobpostingManager
                                          .filteredPosts[index]);
                                    },
                                  ),
                                )
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                    ),
                                    child: Text(
                                      'Chưa có công việc phù hợp',
                                      style: textTheme.bodyLarge!
                                          .copyWith(fontSize: 17),
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      );
                    }),
                  ),
                ),
              );
            }));
  }
}
