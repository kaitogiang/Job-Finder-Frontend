import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/shared/job_card.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatelessWidget {
  const SearchResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    final jobpostingManager = context.read<JobpostingManager>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 90,
        title: TextFormField(
          readOnly: true,
          onTap: () {
            context.pop();
          },
          decoration: InputDecoration(
            constraints: BoxConstraints.tightFor(height: 60),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: 'Tìm kiếm lĩnh vực của bạn',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (value) {
            //todo Lưu từ khóa vào bộ nhớ điện thoại để hiển thị lịch sử
          },
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Kết quả tìm kiếm',
              style: textTheme.titleMedium!.copyWith(
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            context.read<JobpostingManager>().searchResults.isNotEmpty
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Consumer<JobpostingManager>(
                          builder: (context, jobpostingManager, child) {
                        return Column(
                          children: List<Widget>.generate(
                            jobpostingManager.searchResults.length,
                            (index) => JobCard(
                              jobpostingManager.searchResults[index],
                            ),
                          ),
                        );
                      }),
                    ),
                  )
                : Center(
                    child: Text(
                      'Không tìm thấy thông tin tuyển dụng',
                      style: textTheme.bodyLarge!.copyWith(
                        fontSize: 17,
                      ),
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            if (jobpostingManager.searchResults.isEmpty)
              Text(
                'Gợi ý cho bạn',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 18,
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            if (jobpostingManager.searchResults.isEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: jobpostingManager.randomJobposting.length > 10
                      ? 10
                      : jobpostingManager.randomJobposting.length,
                  itemBuilder: (context, index) {
                    return JobCard(jobpostingManager.randomJobposting[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
