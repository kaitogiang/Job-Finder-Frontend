import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/shared/job_card.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchJobScreen extends StatefulWidget {
  const SearchJobScreen({super.key});

  @override
  State<SearchJobScreen> createState() => _SearchJobScreenState();
}

class _SearchJobScreenState extends State<SearchJobScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  late SharedPreferences prefs;
  ValueNotifier<List<String>> _historyListenable = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  //todo Khởi tạo SharedPreferences
  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    _historyListenable.value = prefs.getStringList('searchHistory') ?? [];
  }

  //todo Hàm lưu từ khóa vào trong bộ nhớ cục bộ của điện thoại
  Future<void> saveSearchKeyword(String keyword) async {
    List<String> searchHistory = prefs.getStringList('searchHistory') ?? [];
    if (!searchHistory.contains(keyword)) {
      searchHistory.add(keyword);
      prefs.setStringList('searchHistory', searchHistory);
      _historyListenable.value = searchHistory;
    }
  }

  //todo Hàm xóa lịch sử tìm kiếm
  Future<void> clearSearchHistory(SharedPreferences prefs) async {
    await prefs.remove('searchHistory');
    _historyListenable.value = [];
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    final suggestionJobposting =
        context.watch<JobpostingManager>().randomJobposting;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Tìm kiếm công việc',
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
          preferredSize: const Size.fromHeight(150),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Tìm kiếm công việc yêu thích của bạn tại đây',
                  style: textTheme.titleMedium!.copyWith(
                    color: theme.indicatorColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onTap: () {},
                  decoration: InputDecoration(
                    constraints: BoxConstraints.tightFor(height: 60),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    hintText: 'Tìm kiếm lĩnh vực của bạn',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (value) async {
                    if (value.isEmpty) {
                      return;
                    }
                    //todo Lưu từ khóa vào bộ nhớ điện thoại để hiển thị lịch sử
                    saveSearchKeyword(value);

                    context.read<JobpostingManager>().search(value);
                    context.pushNamed('search-result');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        children: <Widget>[
          //todo Phần hiển thị tìm kiếm gần đây
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Tìm kiếm gần đây',
                style: textTheme.titleMedium!.copyWith(
                  fontSize: 18,
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: _historyListenable,
                  builder: (context, history, child) {
                    return TextButton(
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                      ),
                      onPressed: history.isEmpty
                          ? null
                          : () {
                              clearSearchHistory(prefs);
                            },
                      child: Text(
                        'Xóa lịch sử',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    );
                  })
            ],
          ),
          ValueListenableBuilder(
              valueListenable: _historyListenable,
              builder: (context, history, child) {
                final lastIndex = history.length - 1;
                //! length này không phải là chiều dài mà là phần tử cuối cùng
                //! nếu list có 8 phần tử thì phần tử cuối ở chỉ số 7
                //! Bên dưới có dùng length - index = 7 - 0, với index = 0 lúc đầu
                //! nên sẽ ra đúng, còn nếu để length = 8 thì 8 - 0 = 8 là sai
                //! vì không có chỉ số 8 đâu
                final length = history.length;
                return _historyListenable.value.isNotEmpty
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        reverse: false,
                        shrinkWrap: true,
                        itemCount: length <= 5 ? length : 5,
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            leading: Icon(Icons.access_time_outlined),
                            title: Text(history[lastIndex - index]),
                            onTap: () {
                              _searchController.text =
                                  history[lastIndex - index];
                              _focusNode.requestFocus();
                            },
                          );
                        })
                    : Center(
                        child: Text(
                          'Bạn chưa có lịch sử tìm kiếm gần đây',
                          style: textTheme.bodyLarge,
                        ),
                      );
              }),
          const SizedBox(
            height: 10,
          ),
          // ListTile(
          //   contentPadding: EdgeInsets.symmetric(horizontal: 0),
          //   leading: Icon(Icons.access_time_outlined),
          //   title: Text('Lập trình Nodejs developer'),
          // ),
          // ListTile(
          //   contentPadding: EdgeInsets.symmetric(horizontal: 0),
          //   leading: Icon(Icons.access_time_outlined),
          //   title: Text('Tuyển dụng Front end'),
          // ),
          // ListTile(
          //   contentPadding: EdgeInsets.symmetric(horizontal: 0),
          //   leading: Icon(Icons.access_time_outlined),
          //   title: Text('Tuyển dụng Back end'),
          // ),
          //todo Phần gợi ý từ khóa tìm kiếm
          Text(
            'Từ khóa gợi ý',
            style: textTheme.titleMedium!.copyWith(
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 10,
            children: [
              SuggestionChip(
                title: 'Tester',
                onPressed: () {
                  _searchController.text = 'Tester';
                  _focusNode.requestFocus();
                },
              ),
              SuggestionChip(
                title: 'Java',
                onPressed: () {
                  _searchController.text = 'Java';
                  _focusNode.requestFocus();
                },
              ),
              SuggestionChip(
                title: 'Fresher',
                onPressed: () {
                  _searchController.text = 'Fresher';
                  _focusNode.requestFocus();
                },
              ),
              SuggestionChip(
                title: 'Frontend',
                onPressed: () {
                  _searchController.text = 'Frontend';
                  _focusNode.requestFocus();
                },
              ),
              SuggestionChip(
                title: 'Backend',
                onPressed: () {
                  _searchController.text = 'Backend';
                  _focusNode.requestFocus();
                },
              ),
              SuggestionChip(
                title: 'Engineer',
                onPressed: () {
                  _searchController.text = 'Engineer';
                  _focusNode.requestFocus();
                },
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Việc làm đề xuất',
            style: textTheme.titleMedium!.copyWith(
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            children: List<Widget>.generate(suggestionJobposting.length,
                (index) => JobCard(suggestionJobposting[index])),
          )
        ],
      ),
    );
  }
}

class SuggestionChip extends StatelessWidget {
  const SuggestionChip({
    super.key,
    this.onPressed,
    required this.title,
  });

  final String title;
  final Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(
        title,
        style: TextStyle(
          color: Colors.blue[700]!,
        ),
      ),
      avatar: Icon(
        Icons.search,
        color: Colors.blue[700],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.blue[100]!,
        ),
      ),
      backgroundColor: Colors.blue[100],
      onPressed: onPressed,
    );
  }
}
