import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/shared/job_card.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:provider/provider.dart';

class EmployerJobposting extends StatelessWidget {
  const EmployerJobposting({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final chipColor = Color.fromRGBO(87, 133, 248, 1);
    String companyId = context.read<AuthManager>().employer!.companyId;
    List<String> filteredData = ['Tất cả', 'Còn hạn', 'Hết hạn'];
    List<TimeFilter> condition = [
      TimeFilter.all,
      TimeFilter.notExpired,
      TimeFilter.expired
    ];
    ValueNotifier<int> _selectedIndex = ValueNotifier(0);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bài đăng của tôi',
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: ValueListenableBuilder(
              valueListenable: _selectedIndex,
              builder: (context, selectedIndex, child) {
                return Wrap(
                  runAlignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  spacing: 10,
                  children: List<Widget>.generate(
                    filteredData.length,
                    (index) => InputChip(
                      label: Text(
                        filteredData[index],
                        style: TextStyle(
                            color: index == selectedIndex
                                ? Colors.white
                                : theme.primaryColor),
                      ),
                      selected: index == selectedIndex,
                      elevation: 2,
                      checkmarkColor: Colors.white,
                      selectedColor: chipColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: index == selectedIndex
                              ? const BorderSide(color: Colors.white, width: 1)
                              : BorderSide.none),
                      onSelected: (value) {
                        _selectedIndex.value = index;
                        context
                            .read<JobpostingManager>()
                            .filterCompanyPosts(condition[index]);
                      },
                    ),
                  ),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blueAccent,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
          future:
              context.read<JobpostingManager>().fetchCompanyPosts(companyId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => context
                  .read<JobpostingManager>()
                  .fetchCompanyPosts(companyId),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Consumer<JobpostingManager>(
                    builder: (context, jobpostingManager, child) {
                  final posts = jobpostingManager.filteredCompanyPosts;
                  return ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Số lượng bài đăng: ${posts.length}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return JobCard(
                            posts[index],
                            isEmployer: true,
                          );
                        },
                      ),
                    ],
                  );
                }),
              ),
            );
          }),
    );
  }
}
