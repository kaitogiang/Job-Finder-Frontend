import 'dart:developer';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/models/jobposting.dart';

import '../../shared/job_card.dart';

class JobPageView extends StatefulWidget {
  const JobPageView(this.random, {super.key});
  final List<Jobposting>? random;
  @override
  State<JobPageView> createState() => _JobPageViewState();
}

class _JobPageViewState extends State<JobPageView>
    with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;
  int tabLength = 0;
  List<Jobposting> list = [];
  @override
  void initState() {
    super.initState();
    int randomLength;
    if (widget.random != null) {
      randomLength = widget.random!.length;
      list = widget.random!;
      log('Random length la: $randomLength');
    } else {
      randomLength = 0;
    }
    if (randomLength <= 3) {
      tabLength = 1;
    } else if (randomLength <= 6) {
      tabLength = 2;
    } else {
      tabLength = 3;
    }
    log('Tab lengh: $tabLength');
    _pageViewController = PageController();
    _tabController = TabController(length: tabLength, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 760),
          child: ExpandablePageView(
            controller: _pageViewController,
            onPageChanged: _handlePageViewChanged,
            children: <Widget>[
              if (tabLength >= 1)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                      list.length >= 3 ? 3 : list.length,
                      (index) => JobCard(list[index])),
                ),
              if (tabLength >= 2)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                      list.length >= 6 ? 3 : list.length - 3,
                      (index) => JobCard(list[index + 3])),
                ),
              if (tabLength == 3)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                      list.length >= 9 ? 3 : list.length - 6,
                      (index) => JobCard(list[index + 6])),
                ),
            ],
          ),
        ),
        PageIndicator(
          tabController: _tabController,
          currentPageIndex: _currentPageIndex,
          onUpdateCurrentPageIndex: _updateCurrentPageIndex,
        )
      ],
    );
  }

  //todo Hàm xử lý việc chuyển trang, 1. thay đổi nút được chọn bên dưới,
  //todo 2. Đổi trang
  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(index,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }
}

//? Tạo các nút tab chuyển trang
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(
              Icons.arrow_left_rounded,
              size: 32,
            ),
          ),
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
          IconButton(
            splashRadius: 16,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 2) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(
              Icons.arrow_right_rounded,
              size: 32,
            ),
          )
        ],
      ),
    );
  }
}
