import 'dart:developer';

import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/ui/shared/utils.dart';

import '../../shared/job_card.dart';

class JobPageView extends StatefulWidget {
  const JobPageView(this.random, {super.key});
  final List<Jobposting>? random;
  @override
  State<JobPageView> createState() => _JobPageViewState();
}

class _JobPageViewState extends State<JobPageView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  final ValueNotifier<int> _currentPageIndex = ValueNotifier(0);
  int tabLength = 0;
  List<Jobposting> list = [];
  @override
  void initState() {
    super.initState();
    _intialPageView();
  }

  void _intialPageView() {
    int randomLength;
    if (widget.random != null) {
      randomLength = widget.random!.length;
      list = widget.random!;
      log('Random length is: $randomLength');
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
    log('Tab length: $tabLength');
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
  void didUpdateWidget(covariant JobPageView oldWidget) {
    //implement didUpdateWidget
    Utils.logMessage("Calling didUpdateWidget in JobPageView");
    super.didUpdateWidget(oldWidget);
    if (widget.random != oldWidget.random) {
      _intialPageView();
    }
  }

  @override
  bool get wantKeepAlive => true; // Required for AutomaticKeepAliveClientMixin

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call the super method
    Utils.logMessage("Calling build in JobPageView");
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 820),
          child: ExpandablePageView(
            controller: _pageViewController,
            onPageChanged: _handlePageViewChanged,
            children: <Widget>[
              if (tabLength >= 1)
                Column(
                  key: const PageStorageKey<String>('page1'),
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                      list.length >= 3 ? 3 : list.length,
                      (index) => JobCard(list[index])),
                ),
              if (tabLength >= 2)
                Column(
                  key: const PageStorageKey<String>('page2'),
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                      list.length >= 6 ? 3 : list.length - 3,
                      (index) => JobCard(list[index + 3])),
                ),
              if (tabLength == 3)
                Column(
                  key: const PageStorageKey<String>('page3'),
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                      list.length >= 9 ? 3 : list.length - 6,
                      (index) => JobCard(list[index + 6])),
                ),
            ],
          ),
        ),
        ValueListenableBuilder<int>(
          valueListenable: _currentPageIndex,
          builder: (context, currentPageIndex, child) {
            return PageIndicator(
              tabController: _tabController,
              currentPageIndex: currentPageIndex,
              onUpdateCurrentPageIndex: _updateCurrentPageIndex,
              tabLength: tabLength,
            );
          },
        )
      ],
    );
  }

  //todo Function to handle page change, 1. change the selected button below,
  //todo 2. Change page
  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    _currentPageIndex.value = currentPageIndex;
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(index,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }
}

//? Create page change tab buttons
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.tabLength,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final int tabLength;
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
              if (currentPageIndex == 2 || currentPageIndex == tabLength - 1) {
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
